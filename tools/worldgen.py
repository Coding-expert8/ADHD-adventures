#!/usr/bin/env python3
"""Generates GameMaker assets for the world systems of ADHD adventures.

Close GameMaker before running: the IDE overwrites .yy files it has open.

    python tools/worldgen.py basic     collision shape tiles + scr_collision_data, player mask, trigger/spawn markers
    python tools/worldgen.py world     ts_world: every tileset in tools/world.json combined into one tileset
    python tools/worldgen.py terrain   ts_terrain atlas + scr_terrain_data from tools/terrains.json
    python tools/worldgen.py props     spr_prop_* sprites from tools/props.json (keeps hitboxes edited in GameMaker
                                       unless --reset-hitboxes is given)
    python tools/worldgen.py props --scan _01___Tileset___Transparent
                                       list the separate image regions of a tileset (helps write props.json)

Output is deterministic (GUIDs are derived from asset names) and files are only written when their
content changes, so running a command twice with the same input changes nothing.
"""
import argparse
import io
import json
import math
import re
import string
import uuid
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
PROJECT = REPO / "ADHD adventures"
YYP = PROJECT / "ADHD adventures.yyp"

TILE = 32
ATLAS_COLUMNS = 8
GUID_NAMESPACE = uuid.UUID("5d0c7a3e-6a4f-4d8e-9a57-2f1d3c9b8e41")

WORLD_FOLDER = ("World", "folders/Sprites/World.yy")
PROPS_FOLDER = ("Props", "folders/Sprites/Props.yy")
TILESETS_FOLDER = ("Tilesets", "folders/Tilesets.yy")
SCRIPTS_FOLDER = ("Scripts", "folders/Scripts.yy")

MISSING_COLOUR = (255, 0, 255, 255)

EMPTY_TILE = -2147483648   # "no tile" in room and brush tile data
TILE_INDEX_MASK = 0x7FFFF  # the rest of a tile value holds mirror/flip/rotate flags
MAX_TEXTURE = 4096         # texture page size set in options_windows.yy

# Transition layouts: (col, row) inside the block -> mask of the corners that are terrain b
# (TL 1, TR 2, BL 4, BR 8). "hole" = a surrounds a patch of b, "island" = b surrounds a patch of a.
LAYOUTS = {
    "hole3": {(0, 0): 8, (1, 0): 12, (2, 0): 4, (0, 1): 10, (1, 1): 15, (2, 1): 5, (0, 2): 2, (1, 2): 3, (2, 2): 1},
    "island3": {(0, 0): 7, (1, 0): 3, (2, 0): 11, (0, 1): 5, (1, 1): 0, (2, 1): 10, (0, 2): 13, (1, 2): 12, (2, 2): 14},
    "hole2": {(0, 0): 8, (1, 0): 4, (0, 1): 2, (1, 1): 1},
    "island2": {(0, 0): 7, (1, 0): 11, (0, 1): 13, (1, 1): 14},
}


# ---------------------------------------------------------------------------------------------
# File helpers

def guid(*parts):
    return str(uuid.uuid5(GUID_NAMESPACE, "/".join(parts)))


def write_bytes(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_bytes() == data:
        return
    path.write_bytes(data)
    print("wrote", path.relative_to(REPO))


def write_text(path, text):
    write_bytes(path, text.encode("utf-8"))


def png_bytes(img):
    buf = io.BytesIO()
    img.save(buf, "PNG")
    return buf.getvalue()


def register(kind_dir, name, folder):
    """Adds a resource and its virtual folder to the .yyp when they are missing."""
    text = YYP.read_text(encoding="utf-8")
    path = f"{kind_dir}/{name}/{name}.yy"
    if f'"path":"{path}"' not in text:
        anchor = '  ],\n  "resourceType":"GMProject"'
        entry = f'    {{"id":{{"name":"{name}","path":"{path}",}},}},\n'
        i = text.index(anchor)
        text = text[:i] + entry + text[i:]
    if f'"folderPath":"{folder[1]}"' not in text:
        anchor = '  ],\n  "ForcedPrefabProjectReferences"'
        entry = (f'    {{"$GMFolder":"","%Name":"{folder[0]}","folderPath":"{folder[1]}","name":"{folder[0]}",'
                 f'"resourceType":"GMFolder","resourceVersion":"2.0",}},\n')
        i = text.index(anchor)
        text = text[:i] + entry + text[i:]
    write_text(YYP, text)


def decode_tiles(text):
    """Expands TileCompressedData (format 1): negative n repeats the next value, positive n = n literals."""
    values = [int(v) for v in text.replace("\n", "").split(",") if v.strip()]
    cells, i = [], 0
    while i < len(values):
        n = values[i]
        if n < 0:
            cells += [values[i + 1]] * -n
            i += 2
        else:
            cells += values[i + 1:i + 1 + n]
            i += 1 + n
    return cells


def encode_tiles(cells, indent):
    """Compresses tile values into TileCompressedData lines (20 values per line)."""
    out, literal, i = [], [], 0
    while i < len(cells):
        j = i
        while j < len(cells) and cells[j] == cells[i]:
            j += 1
        if j - i >= 3:
            if literal:
                out += [len(literal)] + literal
                literal = []
            out += [-(j - i), cells[i]]
        else:
            literal += cells[i:j]
        i = j
    if literal:
        out += [len(literal)] + literal
    return "\n".join(" " * indent + ",".join(str(v) for v in out[k:k + 20]) + "," for k in range(0, len(out), 20))


def remap_tile(value, remap_index):
    """Applies remap_index to the tile index inside a tile value, keeping its flags."""
    if value in (0, EMPTY_TILE):
        return value
    unsigned = value & 0xFFFFFFFF
    new = (unsigned & ~TILE_INDEX_MASK & 0xFFFFFFFF) | remap_index(unsigned & TILE_INDEX_MASK)
    return new - (1 << 32) if new & 0x80000000 else new


def tileset_info(tileset_name):
    """Returns (source sprite name, brush page as (width, height, cells) or None) of a tileset asset."""
    yy = (PROJECT / "tilesets" / tileset_name / f"{tileset_name}.yy").read_text(encoding="utf-8")
    sprite = re.search(r'"spriteId":\{\s*"name":"([^"]+)"', yy).group(1)
    page = re.search(r'"macroPageTiles":\{\s*"SerialiseHeight":(\d+),\s*"SerialiseWidth":(\d+),\s*'
                     r'"TileCompressedData":\[(.*?)\]', yy, re.S)
    brushes = None
    if page and int(page.group(1)) > 0:
        brushes = (int(page.group(2)), int(page.group(1)), decode_tiles(page.group(3)))
    return sprite, brushes


def tileset_source(sprite_name):
    """Loads the image of an existing single-frame sprite (e.g. a tileset source sprite)."""
    yy = (PROJECT / "sprites" / sprite_name / f"{sprite_name}.yy").read_text(encoding="utf-8")
    frame = re.search(r'"\$GMSpriteFrame":"v1","%Name":"([^"]+)"', yy).group(1)
    return Image.open(PROJECT / "sprites" / sprite_name / f"{frame}.png").convert("RGBA")


# ---------------------------------------------------------------------------------------------
# Resource writers (field names and order follow the GameMaker LTS 2026 schema)

SPRITE_YY = string.Template("""{
  "$$GMSprite":"v2",
  "%Name":"$name",
  "bboxMode":2,
  "bbox_bottom":$bottom,
  "bbox_left":$left,
  "bbox_right":$right,
  "bbox_top":$top,
  "collisionKind":1,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
    {"$$GMSpriteFrame":"v1","%Name":"$frame","name":"$frame","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},
  ],
  "gridX":0,
  "gridY":0,
  "height":$height,
  "HTile":false,
  "layers":[
    {"$$GMImageLayer":"","%Name":"$layer","blendMode":0,"displayName":"default","isLocked":false,"name":"$layer","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,},
  ],
  "name":"$name",
  "nineSlice":null,
  "origin":$origin,
  "parent":{
    "name":"$folder_name",
    "path":"$folder_path",
  },
  "preMultiplyAlpha":false,
  "resourceType":"GMSprite",
  "resourceVersion":"2.0",
  "sequence":{
    "$$GMSequence":"v1",
    "%Name":"$name",
    "autoRecord":true,
    "backdropHeight":768,
    "backdropImageOpacity":0.5,
    "backdropImagePath":"",
    "backdropWidth":1366,
    "backdropXOffset":0.0,
    "backdropYOffset":0.0,
    "events":{
      "$$KeyframeStore<MessageEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MessageEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "eventStubScript":null,
    "eventToFunction":{},
    "length":1.0,
    "lockOrigin":false,
    "moments":{
      "$$KeyframeStore<MomentsEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MomentsEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "name":"$name",
    "playback":1,
    "playbackSpeed":30.0,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {"$$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"$$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[
            {"$$Keyframe<SpriteFrameKeyframe>":"","Channels":{
                "0":{"$$SpriteFrameKeyframe":"","Id":{"name":"$frame","path":"sprites/$name/$name.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},
              },"Disabled":false,"id":"$keyframe","IsCreationKey":false,"Key":0.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},
          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0,},
    ],
    "visibleRange":null,
    "volume":1.0,
    "xorigin":$xorigin,
    "yorigin":$yorigin,
  },
  "swatchColours":null,
  "swfPrecision":0.5,
  "textureGroupId":{
    "name":"Default",
    "path":"texturegroups/Default",
  },
  "type":0,
  "VTile":false,
  "width":$width,
}""")

TILESET_YY = string.Template("""{
  "$$GMTileSet":"v1",
  "%Name":"$name",
  "autoTileSets":[],
  "macroPageTiles":{
$brushes
  },
  "name":"$name",
  "out_columns":$out_columns,
  "out_tilehborder":2,
  "out_tilevborder":2,
  "parent":{
    "name":"Tilesets",
    "path":"folders/Tilesets.yy",
  },
  "resourceType":"GMTileSet",
  "resourceVersion":"2.0",
  "spriteId":{
    "name":"$sprite",
    "path":"sprites/$sprite/$sprite.yy",
  },
  "spriteNoExport":$no_export,
  "textureGroupId":{
    "name":"Default",
    "path":"texturegroups/Default",
  },
  "tileAnimationFrames":[],
  "tileAnimationSpeed":15.0,
  "tileHeight":$tile_h,
  "tilehsep":0,
  "tilevsep":0,
  "tileWidth":$tile_w,
  "tilexoff":0,
  "tileyoff":0,
  "tile_count":$tile_count,
}""")


def write_sprite(name, img, bbox, folder, centre_origin=False):
    """Writes a single-frame sprite with a manual rectangle collision mask. bbox = (left, top, right, bottom)."""
    width, height = img.size
    frame, layer = guid(name, "frame"), guid(name, "layer")
    directory = PROJECT / "sprites" / name
    data = png_bytes(img)
    write_bytes(directory / f"{frame}.png", data)
    write_bytes(directory / "layers" / frame / f"{layer}.png", data)
    left, top, right, bottom = bbox
    write_text(directory / f"{name}.yy", SPRITE_YY.substitute(
        name=name, frame=frame, layer=layer, keyframe=guid(name, "keyframe"),
        left=left, top=top, right=right, bottom=bottom, width=width, height=height,
        origin=4 if centre_origin else 0,
        xorigin=width // 2 if centre_origin else 0, yorigin=height // 2 if centre_origin else 0,
        folder_name=folder[0], folder_path=folder[1]))
    register("sprites", name, folder)


def write_tileset(name, sprite_name, img, tile_w, tile_h, no_export=False, brushes=None):
    """Writes a tileset over an existing sprite, including the IDE's padded output_tileset.png preview.

    no_export: don't also pack the source sprite into texture pages (for big atlases).
    brushes: the tileset editor's brush page as (width, height, tile values), or None.
    """
    columns, rows = img.width // tile_w, img.height // tile_h
    tile_count = columns * rows
    out_columns = round(math.sqrt(tile_count))
    out_rows = math.ceil(tile_count / out_columns)
    cell_w, cell_h = tile_w + 4, tile_h + 4
    if max(out_columns * cell_w, out_rows * cell_h) > MAX_TEXTURE:
        raise SystemExit(f"{name}: compiled tileset texture would be larger than {MAX_TEXTURE}px")
    out = Image.new("RGBA", (out_columns * cell_w, out_rows * cell_h), (0, 0, 0, 0))
    for i in range(1, tile_count):  # tile 0 is always empty
        sx, sy = (i % columns) * tile_w, (i // columns) * tile_h
        tile = img.crop((sx, sy, sx + tile_w, sy + tile_h))
        if tile.getchannel("A").getbbox() is None:
            continue
        ox, oy = (i % out_columns) * cell_w, (i // out_columns) * cell_h
        # 2px border made by stretching the edge pixels outwards, like the IDE does
        stretch = lambda box, size, at: out.paste(tile.crop(box).resize(size, Image.NEAREST), (ox + at[0], oy + at[1]))
        stretch((0, 0, 1, tile_h), (2, tile_h), (0, 2))
        stretch((tile_w - 1, 0, tile_w, tile_h), (2, tile_h), (tile_w + 2, 2))
        stretch((0, 0, tile_w, 1), (tile_w, 2), (2, 0))
        stretch((0, tile_h - 1, tile_w, tile_h), (tile_w, 2), (2, tile_h + 2))
        for cx, cy, px, py in ((0, 0, 0, 0), (tile_w - 1, 0, tile_w + 2, 0),
                               (0, tile_h - 1, 0, tile_h + 2), (tile_w - 1, tile_h - 1, tile_w + 2, tile_h + 2)):
            stretch((cx, cy, cx + 1, cy + 1), (2, 2), (px, py))
        out.paste(tile, (ox + 2, oy + 2))
    if brushes:
        width, height, cells = brushes
        brush_text = (f'    "SerialiseHeight":{height},\n    "SerialiseWidth":{width},\n    "TileCompressedData":[\n'
                      f'{encode_tiles(cells, 6)}\n    ],\n    "TileDataFormat":1,')
    else:
        brush_text = '    "SerialiseHeight":0,\n    "SerialiseWidth":0,\n    "TileSerialiseData":[],'
    directory = PROJECT / "tilesets" / name
    write_bytes(directory / "output_tileset.png", png_bytes(out))
    write_text(directory / f"{name}.yy", TILESET_YY.substitute(
        name=name, sprite=sprite_name, out_columns=out_columns, tile_w=tile_w, tile_h=tile_h, tile_count=tile_count,
        no_export="true" if no_export else "false", brushes=brush_text))
    register("tilesets", name, TILESETS_FOLDER)


# ---------------------------------------------------------------------------------------------
# basic

COLLISION_CELL = 16
COLLISION_WALKABLE = 22  # empty "walkable" tile: like every painted Collision tile it replaces solid terrain in its cell
# Ramps: pixels moved up (negative) or down per pixel walked to the right while the feet are on the tile.
# 23-26 are non-solid ramp tiles (gentle rising right/left, steep rising right/left). The half-slope wall tiles
# 14-21 carry at their own slope too, so a ramp section moves the walker the same amount in every row.
COLLISION_RAMP_TILES = {23: -0.5, 24: 0.5, 25: -1.0, 26: 1.0}
COLLISION_RAMPS = {**COLLISION_RAMP_TILES, 14: -0.5, 15: -0.5, 16: 0.5, 17: 0.5, 18: 0.5, 19: 0.5, 20: -0.5, 21: -0.5}
# Slow tiles: non-solid; a walker whose feet touch one moves at this fraction of its speed (27 = vertical stairs).
COLLISION_SLOW_TILES = {27: 0.7}


def collision_shapes():
    """Solid-pixel tests for the Collision tiles, in tile order (tile 0 = empty)."""
    n = COLLISION_CELL
    h = n // 2
    shapes = [
        lambda x, y: False,           # 0 empty
        lambda x, y: True,            # 1 full
        lambda x, y: y < h,           # 2 top half
        lambda x, y: y >= h,          # 3 bottom half
        lambda x, y: x < h,           # 4 left half
        lambda x, y: x >= h,          # 5 right half
        lambda x, y: x < h and y < h,     # 6 quarter top-left
        lambda x, y: x >= h and y < h,    # 7 quarter top-right
        lambda x, y: x < h and y >= h,    # 8 quarter bottom-left
        lambda x, y: x >= h and y >= h,   # 9 quarter bottom-right
        lambda x, y: x + y >= n - 1,      # 10 45° slope, solid bottom-right
        lambda x, y: y >= x,              # 11 45° slope, solid bottom-left
        lambda x, y: y <= x,              # 12 45° slope, solid top-right
        lambda x, y: x + y <= n - 1,      # 13 45° slope, solid top-left
    ]
    # 22.5° slopes span two tiles; X runs over both tiles (0..2n-1), surface falls n px over 2n px.
    rising = lambda X: n - (X + 1) // 2        # solid-bottom surface rising to the right
    for first, fn in (
        (14, lambda X, y: y >= rising(X)),                    # 14,15 solid bottom, rising right
        (16, lambda X, y: y >= rising(2 * n - 1 - X)),        # 16,17 solid bottom, rising left
        (18, lambda X, y: y < n - rising(X)),                 # 18,19 solid top, hanging lower to the right
        (20, lambda X, y: y < n - rising(2 * n - 1 - X)),     # 20,21 solid top, hanging lower to the left
    ):
        shapes.append(lambda x, y, fn=fn: fn(x, y))
        shapes.append(lambda x, y, fn=fn: fn(x + n, y))
    shapes.append(lambda x, y: False)  # 22 walkable marker
    shapes += [lambda x, y: False] * len(COLLISION_RAMP_TILES)  # 23-26 ramps
    shapes += [lambda x, y: False] * len(COLLISION_SLOW_TILES)  # 27 slow (stairs)
    return shapes


def cmd_basic(_args):
    # Collision shape tiles (16px) and their row bitmasks for GML.
    n = COLLISION_CELL
    shapes = collision_shapes()
    img = Image.new("RGBA", (8 * n, math.ceil(len(shapes) / 8) * n), (0, 0, 0, 0))
    masks = []
    for i, solid in enumerate(shapes):
        ox, oy = (i % 8) * n, (i // 8) * n
        rows = []
        for y in range(n):
            bits = 0
            for x in range(n):
                if solid(x, y):
                    bits |= 1 << x
                    edge = any(not (0 <= x + dx < n and 0 <= y + dy < n) or not solid(x + dx, y + dy)
                               for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
                    img.putpixel((ox + x, oy + y), (230, 40, 40, 230 if edge else 110))
            rows.append(bits)
        masks.append(rows)
    ImageDraw.Draw(img).rectangle(((COLLISION_WALKABLE % 8) * n, (COLLISION_WALKABLE // 8) * n,
                                   (COLLISION_WALKABLE % 8) * n + n - 1, (COLLISION_WALKABLE // 8) * n + n - 1),
                                  fill=(40, 200, 80, 90), outline=(40, 200, 80, 220))
    for index, rate in COLLISION_RAMP_TILES.items():
        # blue, with stripes running along the slope the walker follows
        ox, oy = (index % 8) * n, (index // 8) * n
        for y in range(n):
            for x in range(n):
                stripe = int(y - rate * x) % (n // 2) < 2
                img.putpixel((ox + x, oy + y), (60, 120, 255, 220 if stripe else 80))
    for index in COLLISION_SLOW_TILES:
        # orange, with horizontal stripes like steps
        ox, oy = (index % 8) * n, (index // 8) * n
        for y in range(n):
            for x in range(n):
                img.putpixel((ox + x, oy + y), (255, 150, 30, 220 if y % 4 == 3 else 80))
    write_sprite("spr_collision_tiles", img, (0, 0, img.width - 1, img.height - 1), WORLD_FOLDER)
    write_tileset("ts_collision", "spr_collision_tiles", img, n, n)

    lines = [
        "// GENERATED by tools/worldgen.py basic - do not edit by hand.",
        "",
        "// Shapes of the ts_collision tiles: 16 rows per tile, bit x set = pixel x of that row is solid.",
        "global.collision_shape = [",
    ]
    lines.append(",\n".join("    [" + ", ".join(str(r) for r in rows) + "]" for rows in masks))
    lines += ["];", f"// Tile {COLLISION_WALKABLE} (green) has no solid pixels: paint it to make solid terrain such as water walkable.",
              "",
              "// Ramps: pixels moved down (negative = up) per pixel walked to the right while standing on the tile.",
              "// Blue tiles 23-26 are ramps; the half-slope wall tiles 14-21 carry at their slope too.",
              "global.collision_ramp = array_create(array_length(global.collision_shape), 0);"]
    lines += [f"global.collision_ramp[{index}] = {rate};" for index, rate in sorted(COLLISION_RAMPS.items())]
    lines += ["",
              "// Speed: fraction of normal speed while the feet touch the tile. Orange tile 27 (stairs) = 70%.",
              "global.collision_speed = array_create(array_length(global.collision_shape), 1);"]
    lines += [f"global.collision_speed[{index}] = {rate};" for index, rate in sorted(COLLISION_SLOW_TILES.items())]
    script = PROJECT / "scripts" / "scr_collision_data"
    write_text(script / "scr_collision_data.gml", "\n".join(lines) + "\n")
    write_text(script / "scr_collision_data.yy", SCRIPT_YY.substitute(name="scr_collision_data"))
    register("scripts", "scr_collision_data", SCRIPTS_FOLDER)

    # Player feet mask: same 190x190 canvas and centre origin as the spr_char_* sprites.
    feet = (65, 150, 124, 179)
    img = Image.new("RGBA", (190, 190), (0, 0, 0, 0))
    ImageDraw.Draw(img).rectangle(feet, fill=(255, 255, 0, 160))
    write_sprite("spr_player_mask", img, feet, WORLD_FOLDER, centre_origin=True)

    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    ImageDraw.Draw(img).rectangle((0, 0, 31, 31), fill=(60, 140, 255, 90), outline=(60, 140, 255, 230))
    write_sprite("spr_trigger", img, (0, 0, 31, 31), WORLD_FOLDER)

    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    ImageDraw.Draw(img).ellipse((4, 4, 27, 27), fill=(60, 220, 90, 120), outline=(60, 220, 90, 240), width=2)
    write_sprite("spr_spawn", img, (0, 0, 31, 31), WORLD_FOLDER, centre_origin=True)


# ---------------------------------------------------------------------------------------------
# world

WORLD_LAYOUT = TOOLS / "ts_world_layout.json"


def cut_cost(img, row):
    """How many of the 8 tile columns have art crossing the boundary above tile row `row`."""
    y = row * TILE
    above = img.crop((0, y - 1, img.width, y)).getchannel("A").tobytes()
    below = img.crop((0, y, img.width, y + 1)).getchannel("A").tobytes()
    return sum(1 for c in range(ATLAS_COLUMNS)
               if any(above[c * TILE:(c + 1) * TILE]) and any(below[c * TILE:(c + 1) * TILE]))


def world_layout(spec, images):
    """Cuts each tileset into strips of at most `column_rows` rows, then stacks the strips in order into
    8-tile-wide atlas columns of that height. Cuts trade strip length against art they split: each tile column
    of art crossing the cut costs as much as 12 rows of strip."""
    column_rows = spec["column_rows"]
    strips, group, top = [], -1, column_rows
    for tileset in spec["tilesets"]:
        img = images[tileset]
        total = img.height // TILE
        row = 0
        while row < total:
            end = min(row + column_rows, total)
            if end < total:
                end = min(range(row + column_rows // 2, end + 1), key=lambda k: cut_cost(img, k) * 12 - k)
            rows = end - row
            if top + rows > column_rows:
                group, top = group + 1, 0
            strips.append({"tileset": tileset, "row": row, "rows": rows, "column": group * ATLAS_COLUMNS, "top": top})
            top += rows
            row = end
    return {"columns": (group + 1) * ATLAS_COLUMNS, "rows": column_rows, "strips": strips}


def world_index_mapper(layout):
    """Returns f(tileset, source tile index) -> ts_world tile index."""
    columns = layout["columns"]
    by_tileset = {}
    for strip in layout["strips"]:
        by_tileset.setdefault(strip["tileset"], []).append(strip)

    def mapper(tileset, index):
        if index == 0:
            return 0
        col, row = index % ATLAS_COLUMNS, index // ATLAS_COLUMNS
        for strip in by_tileset[tileset]:
            if strip["row"] <= row < strip["row"] + strip["rows"]:
                return (strip["top"] + row - strip["row"]) * columns + strip["column"] + col
        raise ValueError(f"{tileset} tile {index} is outside the tileset")
    return mapper


def world_source_of(layout, index):
    """ts_world tile index -> (tileset, source tile index), or None for an unused part of the atlas."""
    columns = layout["columns"]
    col, row = index % columns, index // columns
    for strip in layout["strips"]:
        if strip["column"] <= col < strip["column"] + ATLAS_COLUMNS and strip["top"] <= row < strip["top"] + strip["rows"]:
            return strip["tileset"], (strip["row"] + row - strip["top"]) * ATLAS_COLUMNS + col - strip["column"]
    return None


def remap_world_rooms(old, new):
    """Keeps painted ts_world tiles pointing at the same art after the atlas layout changed."""
    to_new = world_index_mapper(new)
    kept = {s["tileset"] for s in new["strips"]}

    def remap_index(index):
        source = world_source_of(old, index)
        if source is None:
            return 0
        if source[0] not in kept:
            raise SystemExit(f"a room uses tiles from {source[0]}, which is no longer in world.json")
        return to_new(*source)

    pattern = re.compile(r'("TileCompressedData":\[)([^\]]*)(\],"TileDataFormat":1,\},"tilesetId":\{"name":"ts_world")')
    for room in sorted((PROJECT / "rooms").glob("*/*.yy")):
        text = room.read_text(encoding="utf-8")
        new_text = pattern.sub(lambda m: m.group(1) + "\n" + encode_tiles(
            [remap_tile(v, remap_index) for v in decode_tiles(m.group(2))], 10) + "\n        " + m.group(3), text)
        if new_text != text:
            write_text(room, new_text)


def cmd_world(_args):
    spec = json.loads((TOOLS / "world.json").read_text(encoding="utf-8"))
    info = {tileset: tileset_info(tileset) for tileset in spec["tilesets"]}
    images = {tileset: tileset_source(sprite) for tileset, (sprite, _) in info.items()}
    layout = world_layout(spec, images)

    atlas = Image.new("RGBA", (layout["columns"] * TILE, layout["rows"] * TILE), (0, 0, 0, 0))
    for strip in layout["strips"]:
        top = strip["row"] * TILE
        piece = images[strip["tileset"]].crop((0, top, ATLAS_COLUMNS * TILE, top + strip["rows"] * TILE))
        atlas.paste(piece, (strip["column"] * TILE, strip["top"] * TILE))

    # Brush pages of the source tilesets, side by side with one empty column between them.
    to_world = world_index_mapper(layout)
    pages = []
    for tileset, (_, brushes) in info.items():
        if brushes:
            width, height, cells = brushes
            pages.append((width, height, [remap_tile(v, lambda i, t=tileset: to_world(t, i)) for v in cells]))
    brush_page = None
    if pages:
        width = sum(p[0] for p in pages) + len(pages) - 1
        height = max(p[1] for p in pages)
        cells = [0] * (width * height)
        left = 0
        for page_w, page_h, page in pages:
            for y in range(page_h):
                cells[y * width + left:y * width + left + page_w] = page[y * page_w:(y + 1) * page_w]
            left += page_w + 1
        brush_page = (width, height, cells)

    write_sprite("spr_world_atlas", atlas, (0, 0, atlas.width - 1, atlas.height - 1), WORLD_FOLDER)
    write_tileset("ts_world", "spr_world_atlas", atlas, TILE, TILE, no_export=True, brushes=brush_page)
    if WORLD_LAYOUT.exists():
        old = json.loads(WORLD_LAYOUT.read_text(encoding="utf-8"))
        if old != layout:
            remap_world_rooms(old, layout)
    write_text(WORLD_LAYOUT, json.dumps(layout, indent=2) + "\n")

    for strip in layout["strips"]:
        print(f"{strip['tileset']} rows {strip['row']}-{strip['row'] + strip['rows'] - 1}: "
              f"atlas column {strip['column']}, row {strip['top']}")
    print(f"ts_world: {layout['columns']}x{layout['rows']} tiles ({atlas.width}x{atlas.height}px)")


# ---------------------------------------------------------------------------------------------
# terrain

def cmd_terrain(_args):
    spec = json.loads((TOOLS / "terrains.json").read_text(encoding="utf-8"))
    sources = {}

    def source_tile(tileset, col, row):
        if tileset not in sources:
            sources[tileset] = tileset_source(tileset)
        return sources[tileset].crop((col * TILE, row * TILE, (col + 1) * TILE, (row + 1) * TILE))

    ids = {}
    tiles = [Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))]  # atlas tile 0 is always empty
    solid = [False]
    for terrain in spec["terrains"]:
        if terrain["name"] in ids:
            raise SystemExit(f"duplicate terrain {terrain['name']}")
        ids[terrain["name"]] = len(tiles)
        tiles.append(source_tile(terrain["tileset"], *terrain["tile"]))
        solid.append(bool(terrain.get("solid", False)))

    pairs = []  # (a id, b id, base index)
    missing = []
    for pair in spec["pairs"]:
        a, b = ids[pair["a"]], ids[pair["b"]]
        by_mask = {}
        for layout, positions in LAYOUTS.items():
            if layout in pair:
                col, row = pair[layout]
                for (dc, dr), mask in positions.items():
                    by_mask.setdefault(mask, source_tile(pair["tileset"], col + dc, row + dr))
        for mask, (col, row) in pair.get("tiles", {}).items():
            by_mask[int(mask)] = source_tile(pair["tileset"], col, row)
        base = len(tiles)
        for mask in range(16):
            if mask in by_mask:
                tiles.append(by_mask[mask])
            else:
                tiles.append(Image.new("RGBA", (TILE, TILE), MISSING_COLOUR))
                missing.append(base + mask)
        pairs.append((a, b, base))
        absent = [m for m in range(1, 15) if m not in by_mask]
        if absent:
            print(f"note: {pair['a']}/{pair['b']} has no tile for masks {absent}")

    rows = math.ceil(len(tiles) / ATLAS_COLUMNS)
    atlas = Image.new("RGBA", (ATLAS_COLUMNS * TILE, rows * TILE), (0, 0, 0, 0))
    for i, tile in enumerate(tiles):
        atlas.paste(tile, ((i % ATLAS_COLUMNS) * TILE, (i // ATLAS_COLUMNS) * TILE))
    write_sprite("spr_terrain_atlas", atlas, (0, 0, atlas.width - 1, atlas.height - 1), WORLD_FOLDER)
    write_tileset("ts_terrain", "spr_terrain_atlas", atlas, TILE, TILE)

    count = len(spec["terrains"])
    size = count + 1
    lines = [
        "// GENERATED by tools/worldgen.py from tools/terrains.json - do not edit by hand.",
        "// Change the JSON, then run `python tools/worldgen.py terrain` with GameMaker closed.",
        "",
        "// Terrain ids are their palette tile index in ts_terrain (0 = unpainted cell).",
        f"global.terrain_count = {count};",
        "global.terrain_names = [" + ", ".join(['""'] + [f'"{t["name"]}"' for t in spec["terrains"]]) + "];",
        "global.terrain_solid = [" + ", ".join("true" if s else "false" for s in solid) + "];",
        "",
        "// terrain_pair[a][b]: first of the 16 atlas tiles for cell corners holding terrains a and b,",
        "// ordered by a mask of the corners that are b (TL 1, TR 2, BL 4, BR 8).",
        "// flip means the tiles were stored for the reverse pair, so use 15 - mask.",
        f"global.terrain_pair = array_create({size});",
        f"for (var _i = 0; _i < {size}; _i++) global.terrain_pair[_i] = array_create({size}, undefined);",
    ]
    for a, b, base in pairs:
        lines.append(f"global.terrain_pair[{a}][{b}] = {{ base: {base}, flip: false }};")
        lines.append(f"global.terrain_pair[{b}][{a}] = {{ base: {base}, flip: true }};")
    lines += ["", "// Atlas tiles with no art (drawn as the plain terrain and flagged in debug view).",
              f"global.terrain_missing = array_create({len(tiles)}, false);"]
    lines += [f"global.terrain_missing[{i}] = true;" for i in missing]
    script = PROJECT / "scripts" / "scr_terrain_data"
    write_text(script / "scr_terrain_data.gml", "\n".join(lines) + "\n")
    write_text(script / "scr_terrain_data.yy", SCRIPT_YY.substitute(name="scr_terrain_data"))
    register("scripts", "scr_terrain_data", SCRIPTS_FOLDER)
    print(f"{count} terrains, {len(pairs)} pairs, {len(tiles)} atlas tiles ({atlas.width}x{atlas.height})")


SCRIPT_YY = string.Template("""{
  "$$GMScript":"v1",
  "%Name":"$name",
  "isCompatibility":false,
  "isDnD":false,
  "name":"$name",
  "parent":{
    "name":"Scripts",
    "path":"folders/Scripts.yy",
  },
  "resourceType":"GMScript",
  "resourceVersion":"2.0",
}""")


# ---------------------------------------------------------------------------------------------
# props

def body_bbox(img):
    """Bounding box of the clearly opaque pixels (ignores faint baked shadows)."""
    alpha = img.getchannel("A").point(lambda v: 255 if v >= 200 else 0)
    return alpha.getbbox() or (0, 0, img.width, img.height)


def cmd_props(args):
    if args.scan:
        scan(args.scan)
        return
    groups = json.loads((TOOLS / "props.json").read_text(encoding="utf-8"))
    for group in groups:
        source = tileset_source(group["tileset"])
        # one Props subfolder per source tileset
        folder = (group["folder"], f"{PROPS_FOLDER[1][:-3]}/{group['folder']}.yy") if "folder" in group else PROPS_FOLDER
        for prop in group["props"]:
            if "parts" in prop:
                width = max(p["at"][0] + p["rect"][2] for p in prop["parts"])
                height = max(p["at"][1] + p["rect"][3] for p in prop["parts"])
                img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
                for part in prop["parts"]:
                    x, y, w, h = part["rect"]
                    piece = source.crop((x, y, x + w, y + h))
                    img.alpha_composite(piece, tuple(part["at"]))
            else:
                x, y, w, h = prop["rect"]
                img = source.crop((x, y, x + w, y + h))
            if "footprint" in prop:
                footprint = tuple(prop["footprint"])
            else:
                left, top, right, bottom = body_bbox(img)
                body_w, body_h = right - left, bottom - top
                footprint = (left + round(body_w * 0.2), bottom - max(8, round(body_h * 0.5)),
                             right - 1 - round(body_w * 0.2), bottom - 1)
            name = f"spr_prop_{prop['name']}"
            existing = PROJECT / "sprites" / name / f"{name}.yy"
            if existing.exists() and not args.reset_hitboxes:
                yy = existing.read_text(encoding="utf-8")
                current = tuple(int(re.search(rf'"{k}":(\d+)', yy).group(1))
                                for k in ("bbox_left", "bbox_top", "bbox_right", "bbox_bottom"))
                if current != footprint:
                    print(f"keeping the hitbox of {name} set in GameMaker {list(current)} "
                          f"(props.json says {list(footprint)}; --reset-hitboxes overwrites it)")
                    footprint = current
            write_sprite(name, img, footprint, folder)


def scan(tileset):
    """Prints the bounding boxes of connected non-transparent regions (8-neighbour) of a tileset image."""
    img = tileset_source(tileset)
    width, height = img.size
    alpha = img.getchannel("A").tobytes()
    seen = bytearray(width * height)
    regions = []
    for start in range(width * height):
        if seen[start] or not alpha[start]:
            continue
        seen[start] = 1
        queue = deque([start])
        x0 = x1 = start % width
        y0 = y1 = start // width
        pixels = 0
        while queue:
            p = queue.popleft()
            px, py = p % width, p // width
            pixels += 1
            x0, x1, y0, y1 = min(x0, px), max(x1, px), min(y0, py), max(y1, py)
            for dy in (-1, 0, 1):
                ny = py + dy
                if ny < 0 or ny >= height:
                    continue
                for dx in (-1, 0, 1):
                    nx = px + dx
                    if 0 <= nx < width:
                        n = ny * width + nx
                        if not seen[n] and alpha[n]:
                            seen[n] = 1
                            queue.append(n)
        if pixels >= 64:
            regions.append((y0, x0, x1 - x0 + 1, y1 - y0 + 1, pixels))
    for y, x, w, h, pixels in sorted(regions):
        grid = f"tiles c{x // TILE}-{(x + w - 1) // TILE} r{y // TILE}-{(y + h - 1) // TILE}"
        print(f"[{x}, {y}, {w}, {h}]  {grid}  {pixels}px")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("basic").set_defaults(run=cmd_basic)
    sub.add_parser("world").set_defaults(run=cmd_world)
    sub.add_parser("terrain").set_defaults(run=cmd_terrain)
    props = sub.add_parser("props")
    props.add_argument("--scan", metavar="TILESET_SPRITE")
    props.add_argument("--reset-hitboxes", action="store_true",
                       help="overwrite hitboxes edited in GameMaker with the footprints from props.json")
    props.set_defaults(run=cmd_props)
    args = parser.parse_args()
    args.run(args)


if __name__ == "__main__":
    main()

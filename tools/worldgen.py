#!/usr/bin/env python3
"""Generates GameMaker assets for the world systems of ADHD adventures.

Close GameMaker before running: the IDE overwrites .yy files it has open.

    python tools/worldgen.py basic     collision tiles, player mask, trigger/spawn markers
    python tools/worldgen.py terrain   ts_terrain atlas + scr_terrain_data from tools/terrains.json
    python tools/worldgen.py props     spr_prop_* sprites from tools/props.json
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
    "SerialiseHeight":0,
    "SerialiseWidth":0,
    "TileSerialiseData":[],
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
  "spriteNoExport":false,
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


def write_tileset(name, sprite_name, img, tile_w, tile_h):
    """Writes a tileset over an existing sprite, including the IDE's padded output_tileset.png preview."""
    columns, rows = img.width // tile_w, img.height // tile_h
    tile_count = columns * rows
    out_columns = round(math.sqrt(tile_count))
    out_rows = math.ceil(tile_count / out_columns)
    cell_w, cell_h = tile_w + 4, tile_h + 4
    out = Image.new("RGBA", (out_columns * cell_w, out_rows * cell_h), (0, 0, 0, 0))
    for i in range(1, tile_count):  # tile 0 is always empty
        sx, sy = (i % columns) * tile_w, (i // columns) * tile_h
        tile = img.crop((sx, sy, sx + tile_w, sy + tile_h))
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
    directory = PROJECT / "tilesets" / name
    write_bytes(directory / "output_tileset.png", png_bytes(out))
    write_text(directory / f"{name}.yy", TILESET_YY.substitute(
        name=name, sprite=sprite_name, out_columns=out_columns, tile_w=tile_w, tile_h=tile_h, tile_count=tile_count))
    register("tilesets", name, TILESETS_FOLDER)


# ---------------------------------------------------------------------------------------------
# basic

def cmd_basic(_args):
    # Collision tiles: 16px, tile 0 empty, tile 1 solid.
    img = Image.new("RGBA", (32, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle((16, 0, 31, 15), fill=(230, 40, 40, 110), outline=(230, 40, 40, 220))
    write_sprite("spr_collision_tiles", img, (0, 0, 31, 15), WORLD_FOLDER)
    write_tileset("ts_collision", "spr_collision_tiles", img, 16, 16)

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
                footprint = (left + round(body_w * 0.2), bottom - max(4, round(body_h * 0.25)),
                             right - 1 - round(body_w * 0.2), bottom - 1)
            write_sprite(f"spr_prop_{prop['name']}", img, footprint, PROPS_FOLDER)


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
    sub.add_parser("terrain").set_defaults(run=cmd_terrain)
    props = sub.add_parser("props")
    props.add_argument("--scan", metavar="TILESET_SPRITE")
    props.set_defaults(run=cmd_props)
    args = parser.parse_args()
    args.run(args)


if __name__ == "__main__":
    main()

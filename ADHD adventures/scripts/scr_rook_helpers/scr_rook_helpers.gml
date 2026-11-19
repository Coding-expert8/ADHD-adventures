function scr_rook_board_signature() {
    var _signature = "";
    for (var _r = 0; _r < 4; _r++) {
        for (var _c = 0; _c < 4; _c++) {
            var _piece = global.board[_r][_c];
            if (_piece == noone) {
                _signature += ".|";
            } else {
                _signature += string(_piece.type) + "," + string(_piece.color) + "|";
            }
        }
    }
    return _signature;
}

function scr_rook_hand_total() {
    return array_length(global.hand[COLOR_WHITE])
        + array_length(global.hand[1 - COLOR_WHITE]);
}

function scr_rook_board_count() {
    var _count = 0;
    for (var _r = 0; _r < 4; _r++) {
        for (var _c = 0; _c < 4; _c++) {
            if (global.board[_r][_c] != noone) _count += 1;
        }
    }
    return _count;
}

function scr_rook_say(_message) {
    global.rook_speech_text = _message;
    global.rook_speech_timer = ceil(room_speed * 3); // Five seconds per line.
}

function scr_rook_random_line(_lines) {
    return _lines[irandom(array_length(_lines) - 1)];
}

function scr_rook_react(_actor, _captured, _checked_side) {
    var _line = "";

    if (global.game_over) {
        if (global.winner == global.bot_color) {
            _line = scr_rook_random_line([
                "Well played. But this one belongs to me.",
                "Another game for my imaginary trophy cabinet.",
                "A good match. I shall try not to look too pleased."
            ]);
        } else if (global.winner == (1 - global.bot_color)) {
            _line = scr_rook_random_line([
                "You got me. I will be thinking about that one.",
                "A fine game. I demand a rematch.",
                "I may have underestimated you. Only slightly."
            ]);
        } else {
            _line = "A draw. I suppose we are evenly matched.";
        }
    }
    else if (_checked_side != -1) {
        if (_checked_side == global.bot_color) {
            _line = scr_rook_random_line([
                "Nice check. I did not see that coming.",
                "You've checked me. How rude.",
                "Well, that is inconvenient.",
                "Good eye. I will need to be careful."
            ]);
        } else {
            _line = scr_rook_random_line([
                "Check. Did you see that coming?",
                "Your king looks rather nervous.",
                "A little reminder to protect your king.",
                "Check! I do enjoy this part."
            ]);
        }
    }
    else if (_captured) {
        if (_actor == global.bot_color) {
            _line = scr_rook_random_line([
                "I'll be taking that.",
                "Thank you. I will look after it.",
                "That piece was just waiting to join my collection.",
                "Mine now. House rules."
            ]);
        } else {
            _line = scr_rook_random_line([
                "Great capture. I was using that one.",
                "Give that back! I was saving it.",
                "Well taken. I shall pretend I meant that.",
                "That piece had a name, you know.",
                "I was rather fond of that one."
            ]);
        }
    }
    else if (irandom(4) == 0) {
        _line = scr_rook_random_line([
            "You know, I've never lost a game in three years.",
			"I call this move Rook's gambit",
            "I played in the Grand Chess Tournament. Lovely sandwiches.",
            "I've memorised 47 openings. And one excellent joke.",
            "Do not mind me. I am thinking several moves ahead.",
            "Is it just me, or is this board getting smaller?",
            "That was not a mistake. It was a strategic experiment.",
            "You're making this more interesting than I expected.",
            "I should really dust off my trophy cabinet.",
            "I once won a game without moving my favourite piece.",
            "A calm mind is the key to chess. I am perfectly calm."
        ]);
    }

    if (_line != "") scr_rook_say(_line);
}
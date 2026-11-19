if (typing_name()) exit; // the key is a letter in the name popup (obj_login)
if (room == room_answer) exit; // letters are typed as answers in the falling-blocks game
room_goto(room_tinyhouse_help);
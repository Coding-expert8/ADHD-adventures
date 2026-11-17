persistent = true;

// Default values
if (!variable_global_exists("health")) global.health = 3;
if (!variable_global_exists("coins")) global.coins = 0;

if (!variable_global_exists("won_answer")) global.won_answer = false;
if (!variable_global_exists("won_tinyhouse")) global.won_tinyhouse = false;
if (!variable_global_exists("won_snake")) global.won_snake = false;

// Load saved progress
if (file_exists("save.ini"))
{
    ini_open("save.ini");

    global.health = ini_read_real("Player", "Health", global.health);
    global.coins = ini_read_real("Player", "Coins", global.coins);

    global.won_answer = ini_read_real("Progress", "Answer", global.won_answer);
    global.won_tinyhouse = ini_read_real("Progress", "Tinyhouse", global.won_tinyhouse);
    global.won_snake = ini_read_real("Progress", "Snake", global.won_snake);

    ini_close();
}
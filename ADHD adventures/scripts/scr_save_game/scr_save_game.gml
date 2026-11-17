function scr_save_game()
{
    ini_open("save.ini");

    // Player information
    ini_write_real("Player", "Health", global.health);
    ini_write_real("Player", "Coins", global.coins);

    // Minigame progression
    ini_write_real("Progress", "Answer", global.won_answer);
    ini_write_real("Progress", "Tinyhouse", global.won_tinyhouse);
    ini_write_real("Progress", "Snake", global.won_snake);

    ini_close();
}
function scr_sidequest_data()
{
    global.sq_names = [
        "Villager", "Explorer", "Fisher", "Gardener", "Traveller",
        "Shopkeeper", "Artist", "Courier", "Climber", "Cook",
        "Wanderer", "Ranger", "Resident", "Builder", "Musician",
        "Sailor", "Hiker", "Collector", "Villager", "Explorer",
        "Fisher", "Gardener", "Traveller", "Shopkeeper", "Artist",
        "Courier", "Climber", "Cook", "Wanderer", "Ranger"
    ];

    global.sq_descriptions = [
        "Could you visit the city and explore its main square?",
        "Could you walk through the forest and see what you find?",
        "Could you visit the lake and look around?",
        "Could you explore the village paths?",
        "Could you visit the desert and tell me what it is like?",
        "Could you find the traveller who knows the way through the forest?",
        "Could you find the person who works near the lake?",
        "Could you locate the villager who knows about the town?",
        "Could you find the explorer near the summit?",
        "Could you find the person waiting near the village?",
        "Could you inspect the old sign for me?",
        "Could you take a closer look at the notice board?",
        "Could you inspect the old structure?",
        "Could you visit the landmark near the lake?",
        "Could you check the festival decorations?",
        "Could you inspect the old building?",
        "Could you look at the sign near the forest?",
        "Could you inspect the landmark in the desert?",
        "Could you collect three flowers for me?",
        "Could you gather three useful items?",
        "Could you collect three things from around the lake?",
        "Could you find three keepsakes?",
        "Could you collect three parcels?",
        "Could you gather three items from the town?",
        "Could you collect three objects from the forest?",
        "Could you find three things near the village?",
        "Could you collect three items from the desert?",
        "Could you gather three objects near the summit?",
        "Could you collect three things from the island?",
        "Could you find three useful items for me?"
    ];

    global.sq_types = array_create(30, "explore");

    for (var i = 10; i <= 17; i++)
        global.sq_types[i] = "find_npc";

    for (var i = 18; i <= 25; i++)
        global.sq_types[i] = "landmark";

    for (var i = 26; i <= 29; i++)
        global.sq_types[i] = "collect";
}
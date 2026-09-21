has_spawned_next = false; 
spawn_x = 100
spawn_y = 50
can_fall = true

if !variable_global_exists("spacing")
	global.spacing = 0

if !variable_global_exists("word_input")
	global.word_input = ""

if !variable_global_exists("current_q")
	global.current_q = 0

if !variable_global_exists("round_time")
	global.round_time = 600

if !variable_global_exists("round_timer")
	global.round_timer = global.round_time

if !variable_global_exists("controller_instance")
	global.controller_instance = noone

if !variable_global_exists("questions") {

	global.questions[0] = "Name something cold."
	global.answers[0] = ["ice","snow","winter","frost","freezer","glacier","antarctica","icicle","frozen","cold","chilly","iceberg","snowman","hail","sleet","arctic","icecube","fridge","blizzard","permafrost","tundra","icerink","icewater","northpole","southpole","freeze","icicles","snowflake","snowfall","chill","cryo","icecap","polar","icesheet","brrr","cool"]

	global.questions[1] = "Name a type of animal."
	global.answers[1] = ["dog","cat","lion","tiger","elephant","zebra","giraffe","monkey","bear","wolf","fox","rabbit","horse","cow","pig","sheep","goat","deer","kangaroo","panda","koala","cheetah","leopard","hippo","rhino","gorilla","chimpanzee","otter","raccoon","squirrel","hedgehog","bat","camel","donkey","mule","llama","alpaca","moose","elk","bison","buffalo","antelope","gazelle","hyena","jackal","meerkat","mongoose","porcupine","sloth","armadillo","skunk"]

	global.questions[2] = "Name something you find in a kitchen."
	global.answers[2] = ["fridge","refrigerator","oven","stove","microwave","sink","spoon","fork","knife","plate","pan","pot","kettle","blender","toaster","cupboard","dishwasher","bowl","cutleryset","cuttingboard","colander","spatula","whisk","ladle","tongs","grater","peeler","apron","dishrag","towel","napkin","cup","mug","glass","jar","canopener","freezer","stovetop","countertop","pantry","cabinet","tablecloth","placemat","saucepan","skillet","griddle","mixer","foodprocessor","tupperware","cookbook"]

	global.questions[3] = "Name a country."
	global.answers[3] = ["france","germany","spain","italy","canada","mexico","japan","china","india","brazil","australia","egypt","russia","england","america","usa","greece","norway","sweden","kenya","nigeria","southafrica","argentina","chile","peru","colombia","portugal","netherlands","holland","belgium","switzerland","austria","poland","turkey","thailand","vietnam","indonesia","philippines","southkorea","northkorea","ireland","scotland","wales","denmark","finland","iceland","cuba","jamaica","morocco","israel"]

	global.questions[4] = "Name something red."
	global.answers[4] = ["apple","fire","blood","strawberry","tomato","rose","cherry","ruby","lipstick","stopsign","brick","ketchup","wine","firetruck","chili","pepper","raspberry","cranberry","cardinal","radish","watermelon","poppy","valentine","santa","rubies","crimson","scarlet","maroon","redvelvet","ladybug","cherries","apples","tomatoes","stopsigns","fireengine","rednosereindeer","rednose","redcarpet","hotsauce","redwine"]

	global.questions[5] = "Name a sport."
	global.answers[5] = ["soccer","football","basketball","baseball","tennis","golf","swimming","volleyball","hockey","cricket","rugby","boxing","cycling","running","wrestling","badminton","tabletennis","pingpong","surfing","skiing","snowboarding","skating","icehockey","fieldhockey","archery","fencing","gymnastics","rowing","sailing","climbing","bowling","darts","polo","lacrosse","softball","handball","karate","judo","taekwondo","triathlon","marathon","trackandfield","weightlifting","diving","waterpolo","curling","bobsled"]

	global.questions[6] = "Name a fruit."
	global.answers[6] = ["apple","banana","orange","grape","mango","pineapple","strawberry","watermelon","peach","pear","cherry","kiwi","lemon","lime","plum","papaya","blueberry","raspberry","blackberry","apricot","fig","date","coconut","pomegranate","guava","lychee","cantaloupe","honeydew","nectarine","tangerine","clementine","grapefruit","cranberry","passionfruit","dragonfruit","persimmon","plantain","starfruit","kumquat","mandarin"]

	global.questions[7] = "Name something you wear."
	global.answers[7] = ["shirt","pants","shoes","hat","socks","jacket","dress","skirt","sweater","scarf","gloves","belt","tie","shorts","coat","boots","sandals","cardigan","blouse","jeans","hoodie","sweatshirt","vest","suit","blazer","tux","tuxedo","tights","leggings","pajamas","pyjamas","robe","poncho","cape","beanie","cap","earrings","necklace","bracelet","ring","watch","glasses","sunglasses","mittens","slippers","sneakers","heels","flipflops","romper","jumpsuit","overalls","turtleneck","tanktop","camisole","underwear","bra","swimsuit","bikini"]

	global.questions[8] = "Name a job."
	global.answers[8] = ["doctor","teacher","engineer","lawyer","nurse","chef","police","firefighter","pilot","dentist","artist","writer","farmer","plumber","electrician","scientist","actor","musician","accountant","architect","programmer","developer","designer","photographer","journalist","veterinarian","surgeon","pharmacist","therapist","counselor","professor","librarian","mechanic","carpenter","waiter","waitress","bartender","barista","cashier","salesperson","manager","ceo","secretary","receptionist","judge","politician","soldier","athlete","coach"]

	global.questions[9] = "Name something in space."
	global.answers[9] = ["moon","sun","star","planet","comet","asteroid","galaxy","mars","jupiter","saturn","venus","mercury","earth","nebula","meteor","satellite","blackhole","milkyway","uranus","neptune","pluto","astronaut","rocket","spaceship","spacestation","orbit","cosmos","universe","meteorite","supernova","constellation","telescope","spaceshuttle","lunarmodule","spacesuit","alien","ufo","stardust","solarsystem","bigbang"]

	global.questions[10] = "Name a school subject."
	global.answers[10] = ["math","science","history","english","art","music","biology","chemistry","physics","geography","spanish","french","literature","gym","economics","psychology","calculus","algebra","geometry","statistics","sociology","philosophy","government","civics","health","drama","theater","computer","coding","programming","german","latin","chinese","japanese","band","choir","woodshop","homeeconomics"]

	global.questions[11] = "Name a body part."
	global.answers[11] = ["arm","leg","hand","foot","head","eye","ear","nose","mouth","finger","toe","knee","elbow","shoulder","neck","chest","back","stomach","hair","chin","cheek","forehead","eyebrow","eyelash","lip","tongue","tooth","teeth","jaw","wrist","ankle","thigh","calf","hip","waist","spine","rib","lung","heart","brain","liver","kidney","skin","nail","thumb","palm","heel"]

	global.questions[12] = "Name a type of weather."
	global.answers[12] = ["rain","snow","sunny","cloudy","windy","storm","thunder","lightning","fog","hail","hurricane","tornado","drizzle","humid","frost","overcast","breeze","gust","monsoon","blizzard","heatwave","sleet","mist","haze","rainbow","thunderstorm","tropicalstorm","cyclone","typhoon","freezingrain","sunshine","clearsky"]

	global.questions[13] = "Name a vehicle."
	global.answers[13] = ["car","truck","bus","bike","bicycle","motorcycle","train","plane","airplane","boat","ship","scooter","van","taxi","helicopter","submarine","jeep","suv","limousine","tractor","trailer","rv","ambulance","firetruck","policecar","tram","subway","ferry","yacht","canoe","kayak","raft","skateboard","segway","moped","glider","hotairballoon","spaceship","rocket"]

	global.questions[14] = "Name a musical instrument."
	global.answers[14] = ["guitar","piano","drums","violin","flute","trumpet","saxophone","cello","clarinet","harp","trombone","banjo","harmonica","tuba","ukulele","organ","accordion","xylophone","bagpipes","recorder","triangle","tambourine","maracas","bongos","synthesizer","keyboard","viola","doublebass","bass","oboe","piccolo","frenchhorn","electricguitar","acousticguitar"]

	global.questions[15] = "Name a color."
	global.answers[15] = ["red","blue","green","yellow","purple","orange","pink","black","white","brown","gray","grey","gold","silver","turquoise","maroon","navy","teal","magenta","violet","indigo","beige","tan","cyan","lavender","crimson","scarlet","emerald","olive","coral","peach","mint","burgundy","charcoal","ivory","cream","bronze","copper"]

	global.questions[16] = "Name a vegetable."
	global.answers[16] = ["carrot","potato","broccoli","spinach","onion","garlic","pepper","cucumber","lettuce","cabbage","corn","pea","bean","tomato","zucchini","celery","asparagus","cauliflower","eggplant","radish","beet","beetroot","kale","artichoke","squash","pumpkin","sweetpotato","yam","turnip","leek","mushroom","brusselsprout","greenbean","peas"]

	global.questions[17] = "Name something at the beach."
	global.answers[17] = ["sand","wave","ocean","sea","shell","surfboard","towel","umbrella","seaweed","crab","starfish","lifeguard","bikini","sunscreen","sandcastle","shore","cliff","pier","boardwalk","cooler","flipflops","sunhat","volleyball","seashell","tide","driftwood","palmtree","coconut","jellyfish","dolphin","seagull","kite","beachball","raft","cabana"]

	global.questions[18] = "Name a household pet."
	global.answers[18] = ["dog","cat","fish","hamster","rabbit","bird","parrot","turtle","guineapig","lizard","snake","ferret","gerbil","chinchilla","mouse","rat","canary","goldfish","tortoise","hedgehog","cockatiel","parakeet","budgie"]

	global.questions[19] = "Name something cold you eat."
	global.answers[19] = ["icecream","popsicle","sorbet","gelato","slushie","frozenyogurt","sherbet","icedcream","icepop","milkshake","frappe","icedcoffee","icedtea","snowcone","freezepop","fudgesicle","frozengrapes","sundae"]
}
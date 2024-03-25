;Memory Match Data
;games in decreasing binary order: Winter, Extreme, Night, Mega, Normal
;game:{}
MemoryMatchGames := Map(
	"Winter", {bit: 16, cooldown: 14400},
	"Extreme", {bit: 8, cooldown: 28800},
	"Night", {bit: 4, cooldown: 28800},
	"Mega", {bit: 2, cooldown: 14400},
	"Normal", {bit: 1, cooldown: 7200}
)
;(item: variable name):{(name: display name), (games: decimal value of possible games, same format as MatchIgnore variables)}
MemoryMatch := Map(
	"Treat", {name: "Treats", games: 31}, ; 11111
	"SunflowerSeed", {name: "Sunflower Seeds", games: 11}, ; 01011
	"Blueberry", {name: "Blueberries", games: 11}, ; 01011
	"Strawberry", {name: "Strawberries", games: 11}, ; 01011
	"Pineapple", {name: "Pineapples", games: 11}, ; 01011
	"RoyalJelly", {name: "Royal Jellies", games: 11}, ; 01011
	"Gumdrop", {name: "Gumdrops", games: 27}, ; 11011
	"MoonCharm", {name: "Moon Charms", games: 7}, ; 00111
	"Ticket", {name: "Tickets", games: 31}, ; 11111
	"JellyBean", {name: "Jelly Beans", games: 27}, ; 11011
	"MicroConverter", {name: "Micro-Converters", games: 31}, ; 11111
	"FieldDice", {name: "Field Dice", games: 23}, ; 10111
	"MagicBean", {name: "Magic Beans", games: 31}, ; 11111
	"Oil", {name: "Oils", games: 15}, ; 01111
	"Enzyme", {name: "Enzymes", games: 15}, ; 01111
	"Glitter", {name: "Glitter", games: 31}, ; 11111
	"NightBell", {name: "Night Bells", games: 21}, ; 10101
	"Glue", {name: "Glue", games: 22}, ; 10110
	"RedExtract", {name: "Red Extracts", games: 10}, ; 01010
	"BlueExtract", {name: "Blue Extracts", games: 10}, ; 01010
	"Stinger", {name: "Stingers", games: 14}, ; 01110
	"Coconut", {name: "Coconuts", games: 10}, ; 01010
	"StarJelly", {name: "Star Jellies", games: 30}, ; 11110
	"TropicalDrink", {name: "Tropical Drinks", games: 26}, ; 11010
	"CyanTrim", {name: "Cyan Sticker", games: 2}, ; 00010
	"CloudVial", {name: "Cloud Vials", games: 8}, ; 01000
	"SoftWax", {name: "Soft Wax", games: 16}, ; 10000
	"HardWax", {name: "Hard Wax", games: 16}, ; 10000
	"SwirledWax", {name: "Swirled Wax", games: 16}, ; 10000
	"Honeysuckle", {name: "Honeysuckles", games: 16}, ; 10000
	"SuperSmoothie", {name: "Super Smoothies", games: 16}, ; 10000
	"SmoothDice", {name: "Smooth Dice", games: 16}, ; 10000
	"Neonberry", {name: "Neonberries", games: 16}, ; 10000
	"Gingerbread", {name: "Gingerbread Bears", games: 16}, ; 10000
	"SilverEgg", {name: "Silver Eggs", games: 16}, ; 10000
	"GoldEgg", {name: "Gold Eggs", games: 24}, ; 11000
	"DiamondEgg", {name: "Diamond Eggs", games: 25} ; 11001
)

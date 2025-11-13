extends Node

var pre := [
	# Flora
	"Cedar", "Willow", "Maple", "Oak", "Arbutus", "Pine", "Fern", "Birch", "Alder", "Cypress", "Wildflower",
	"Aspen", "Spruce", "Hemlock", "Laurel", "Juniper", "Redwood", "Chestnut", "Dogwood", "Lichen", 
	"Lupine", "Lavender", "Marigold", "Douglas", "Beargrass", "Currant", "Mossy", "Chanterelle", 

	# Fauna
	"Beaver", "Eagle", "Raven", "Cougar", "Chinook", "Sockeye", "Salmon", "Bear", "Heron", "Wolf", "Fox", "Otter",
	"Moose", "Elk", "Falcon", "Hawk", "Deer", "Owl", "Mink", "Badger", "Stallion", "Grouse", "Orca", "Gibbon",
	"Caribou", "Grizzly", "Coyote", "Squirrel", "Woodpecker", "Swallow", "Halibut", "Mallard", "Hummingbird",
	"Butterfly", "Kingfisher", "Dragonfly", "Humpback", "Wren", "Chickadee", "Wigeon", "Jackrabbit", "Bison",

	# Geographic
	"Glacier", "Stone", "Copper", "Prairie", "Cliffside", "Horizon", "Cascade", 
	"Riverbend", "Bayside", "Harbour", "Shoreline", "Oceanview", "Clearwater",
	"Northgate", "Westwood", "Pacific", "Cascadia",
		
	# Cultural
	"Victoria", "Stanley", "Queen's", "King's", "Crown", "Royal", "Centennial",
	"Heritage", "Pioneer", "Frontier", "Goldrush", "Prospector's", "Cowpoke", "Wanderer's", "Rambler's",
	"Lonsdale", "Mackenzie", "Pender", "Banff", "Kootenay", "Revelstoke", "Pacific Rim",
	"Saanich", "Squamish", "Skookumchuck", "Garibaldi", "Cheeckamus", 

	# Other
	"Hidden", "Quiet", "Silent", "Whispering", "Shady", "Sunny", "Tranquil", "Echo", "Misty", "Windy", 
	"Green", "Amber", "Blue", "Brown", "Autumn",  "Bright", "Foggy", "Emerald", "Harmony", "Horseshoe",
	"Golden", "Treasured", "Crystal", "Gnomish", "Fangorn", "Driftwood", "Evil", 
	
	# People
	"McLean", "Schreiber", "Kleve", "Laurillard", "Calder",
	"McLean's", "Schreiber's", "Kleve's", "Laurillard's", "Calder's",
]

var suff := [
	# Water Features
	"Falls", "Waterfall", "Creek", "Lake", "Lakes", "Springs", "Basin", "Rapids", "Shore", "Flats", "Tributaries", "Rill",
	"Brook", "Stream", "Pond", "Lagoon", "Marsh", "Estuary", "Run", "Well", "Reservoir", "Fen", "Runoff", "Wetlands", "Coast",

	# Land Features
	"Slope", "Hill", "Peak", "Summit", "Narrows",
	"Heights", "Plateau", "Knoll", "Valley", "Vista", "Ridge", "Ravine", "Mountain", "Canyon",
	"Cliffs", "Crag", "Slope", "Range",  "Bluff", "Gorge", "Ridgeway", "Headland", "Terrace",
	 
	# Vegetative Feature
	"Meadow", "Hollow", "Canopy", "Clearing", "Clearings", "Fields", "Grove", "Woodlands", "Brush", "Copse", "Coppice",
	"Wilds", "Woods", "Forest", "Greenwood", "Overgrowth", "Heath", "Thicket", "Arbouretum", "Scrublands", "Hurst", "Treeway",

	# Designation Terms  
	"Point", "Pass", "Retreat", "Lookout", "Overlook", "Outlook", "Vista", "Steppe", 
	"Bridge", "Pathlands", "Trail", "Reach", "Crossing", "Landing", "Corridor",
	"Enclave", "Sanctuary", "Sanctum", "Haven", "Hideaway", "Shire",
]

var designation = [
	"Park", "Park", "Park", "Park", "Park", "Park", "Park", "Park", "Park", "Park",
	"Regional Park", "National Park", "Provincial Park", "Parklands", "Campground",
	"Regional Park", "National Park", "Provincial Park", "Parklands", "Campground",
	"Conservation Area", "Ecological Reserve", "Natural Preserve", "Nature Preserve", "Nature Reserve", "Wildlife Refuge",
	"Provincial Forest", "National Forest", "Wildlife Reserve", "Reserve", "Preserve", "Preservation", "Territory"
]

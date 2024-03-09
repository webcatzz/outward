extends Resource

export(String) var name = "Player"

# battle stats
export(int, 100) var level = 1
export(int, 100) var health = 100
export(Array) var party = [
	{
		"name": "Beetle",
		"level": 2,
		"max_health": 20,
		"health": 20,
	},
]

export(Array, Resource) var inventory

# location
export(String) var location = "puddle"
export(PoolStringArray) var visited_locations

#export(int) var time
#export(bool) var has_watch

# settings
export(float, 0, 1, 0.01) var volume = 1
export(float, 0, 1, 0.01) var saturation = 1

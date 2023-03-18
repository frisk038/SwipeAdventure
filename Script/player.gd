extends Node

var state :PlayerState

class PlayerState:
	var life:int
	var atk: int
	var mp: int
	var potion: int
	var luck: int
	var card:int
	
	func reset():
		life = 10
		atk = randi()%10+1
		mp = randi()%10+1
		potion = 5
		luck = randi()%10+1
		card = 0
	
	func save():
		return {
			"atk" : atk, # Vector2 is not supported by JSON
			"mp" : mp,
			"potion" : potion,
			"life" : life,
			"luck" : luck,
			"card" : card
		}

	func read(json):
		for key in json.keys():
			set(key, json[key])

# Called when the node enters the scene tree for the first time.
func _ready():
	state = PlayerState.new()
extends Node

var state :PlayerState

signal player_updated

class PlayerState:
	var life:int
	var atk: int
	var mp: int
	var potion: int
	var money:int
	var luck: int
	var card:int
	
	func reset():
		life = 10
		atk = randi()%10+1
		mp = randi()%10+1
		potion = 5
		luck = randi()%10+1
		card = 0
		money = randi()%99+1
	
	func save():
		return {
			"atk" : atk, # Vector2 is not supported by JSON
			"mp" : mp,
			"potion" : potion,
			"life" : life,
			"luck" : luck,
			"card" : card,
			"money": money
		}

	func read(json):
		for key in json.keys():
			set(key, json[key])
			
func update_stats(member:String, value:int):
	state.set(member, value)
	emit_signal("player_updated")

func _ready():
	state = PlayerState.new()

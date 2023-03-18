extends Node

const file_name="res://savegame.save"

func load_game():
	var file = File.new()
	var err = file.open(file_name, File.READ)
	if err != OK:
		print("no save file !", err)
	var content = file.get_as_text()
	file.close()
	var save = parse_json(content)
	Player.state.read(save)

func save_game():
	var file = File.new()
	var err = file.open(file_name, File.WRITE)
	if err != OK:
		print("can't save file !", err)
	var json_string = to_json(Player.state.save())
	file.store_line(json_string)
	
func new_game():
	Player.state.reset()

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	var err = get_tree().change_scene("res://Scene/game.tscn")
	if err != OK :
		print("cant load game scene")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
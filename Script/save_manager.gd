extends Node

const file_name="user://savegame.save"

func load_game():
	var file = File.new()
	var err = file.open(file_name, File.READ)
	if err != OK:
		print("no save file !", err)
		return false
	var content = file.get_as_text()
	file.close()
	var save = parse_json(content)
	Player.state.read(save)
	return true

func save_game():
	var file = File.new()
	var err = file.open(file_name, File.WRITE)
	if err != OK:
		print("can't save file !", err)
		return false
	var json_string = to_json(Player.state.save())
	file.store_line(json_string)
	return true
func _ready():
	pass

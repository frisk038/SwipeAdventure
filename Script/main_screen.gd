extends Control

onready var loader = $trans_main_screen
onready var main_anim = $AnimationPlayer
onready var loader_anim = $trans_main_screen/AnimationPlayer

const file_name="res://savegame.save"

func load_game():
	var file = File.new()
	var err = file.open(file_name, File.READ)
	if err != OK:
		print("no save file !", err)
		return
	var content = file.get_as_text()
	file.close()
	var save = parse_json(content)
	Player.state.read(save)

func save_game():
	var file = File.new()
	var err = file.open(file_name, File.WRITE)
	if err != OK:
		print("can't save file !", err)
		return
	var json_string = to_json(Player.state.save())
	file.store_line(json_string)
	
func new_game():
	Player.state.reset()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_continue_pressed():
	loader.visible=true
	main_anim.play("reveal")
	yield(main_anim, "animation_finished")
	load_game()
	loader_anim.play("loading")
	yield(loader_anim, "animation_finished")
	loader.visible=false
	
	var err = get_tree().change_scene("res://Scene/game.tscn")
	if err != OK :
		print("cant load game scene")


func _on_new_game_pressed():
	new_game()
	var err = get_tree().change_scene("res://Scene/game.tscn")
	if err != OK :
		print("cant load game scene")


func _on_quit_pressed():
	get_tree().quit()

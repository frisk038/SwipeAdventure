extends Control

onready var loader = $trans_main_screen
onready var main_anim = $AnimationPlayer
onready var loader_anim = $trans_main_screen/AnimationPlayer

func new_game():
	Player.state.reset()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_continue_pressed():
	loader.visible=true
	main_anim.play("reveal")
	yield(main_anim, "animation_finished")
	if !SaveManager.load_game():
		loader.visible=false
		return
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


func _on_settings_pressed():
	print("not implemented")

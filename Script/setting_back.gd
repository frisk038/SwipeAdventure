extends Control


func _ready():
	pass


func _on_settings_pressed():
	print("not implemented")


func _on_back_home_pressed():
	var err = get_tree().change_scene("res://Scene/main_screen.tscn")
	if err != OK :
		print("cant load game scene")

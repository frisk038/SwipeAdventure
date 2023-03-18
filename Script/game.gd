extends Node

onready var roaming_ui = $roaming
#onready var fighting_ui = $Fighting

func updateCard():
	var curCard = GlobalPath.game_path[Player.state.card]
	match curCard.special:
		"Normal":
			roaming_ui.visible=true
			roaming_ui.call("updateState", curCard)
#		"Fight":
#			fighting_ui.visible=true
#			fighting_ui.call("updateState", curCard)

func _on_Path_new_path():
	updateCard()

# Called when the node enters the scene tree for the first time.
func _ready():
	var err = GlobalPath.connect("new_path", self, "_on_Path_new_path")
#	var err = connect("new_path", Path, "_on_Path_new_path")
	if err != OK:
		print("cant connect new_path signal !", err)
	updateCard()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
extends Control

onready var roaming_ui = $roaming_control
onready var fighting_ui = $fight_control

func set_pause_node(node : Node, pause : bool) -> void:
	node.set_process(!pause)
	node.set_process_input(!pause)
	node.set_process_internal(!pause)
	node.set_process_unhandled_input(!pause)
	node.set_process_unhandled_key_input(!pause)

func set_pause_scene(rootNode : Node, pause : bool, ignoredChilds : PoolStringArray = [null]):
	set_pause_node(rootNode, pause)
	for node in rootNode.get_children():
		if not (String(node.get_path()) in ignoredChilds):
			set_pause_scene(node, pause, ignoredChilds)

func updateCard():
	var curCard = GlobalPath.game_path[Player.state.card]
	match curCard.special:
		"Normal":
			set_pause_scene(fighting_ui, true)
			fighting_ui.visible=false
			set_pause_scene(roaming_ui, false)
			roaming_ui.visible=true
			roaming_ui.call("updateState", curCard)
		"Combat":
			set_pause_scene(roaming_ui, true)
			roaming_ui.visible=false
			set_pause_scene(fighting_ui, false)
			fighting_ui.visible=true
			fighting_ui.call("updateState", curCard)

func _on_Path_new_path():
	updateCard()

# Called when the node enters the scene tree for the first time.
func _ready():
	var err = GlobalPath.connect("new_path", self, "_on_Path_new_path")
	if err != OK:
		print("cant connect new_path signal !", err)
	updateCard()

extends Node2D

onready var left_text = $"card/card/AnimatedSprite/hint_left"
onready var up_text = $"card/card/AnimatedSprite/hint_up"
onready var right_text = $"card/card/AnimatedSprite/hint_right"
onready var down_text = $"card/card/AnimatedSprite/hint_down"
onready var img_card = $"card/card/AnimatedSprite"
onready var enemy_name = $"enemy_name"
onready var enemy_life = $"enemy_lp/Label"
onready var enemy_dialog = $"dialogue"
onready var player_life = $"player_lp/Label"
onready var player_mp = $"player_mp/Label"
onready var player_pn = $"player_pn/Label"

var choices:Array

func updateState(pathNode:GlobalPath.PathNode):
	choices = pathNode.paths
	
	img_card.frames.clear("default")
	img_card.frames.add_frame("default", pathNode.img_res)
	enemy_name.text = pathNode.vname
	enemy_dialog.bbcode_text = pathNode.desc_text
	enemy_life.text = str(pathNode.life)
	player_life.text = str(Player.state.life)
	player_mp.text = str(Player.state.mp)
	player_pn.text = str(Player.state.potion)
	left_text.bbcode_text = "[center]Atk Special[/center]"
	right_text.bbcode_text = "[center]Potion[/center]"
	up_text.bbcode_text = "[center]Atk[/center]"
	down_text.bbcode_text = "[center]Fuir[/center]"
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_card_choice_made(choice):
	if visible:
		match choice:
			GlobalPath.LEFT:
				pass
			GlobalPath.UP:
				pass
			GlobalPath.RIGHT:
				pass
			GlobalPath.DOWN:
				pass

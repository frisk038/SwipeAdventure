extends Node2D

onready var left_text = $"card/card/AnimatedSprite/hint_left"
onready var up_text = $"card/card/AnimatedSprite/hint_up"
onready var right_text = $"card/card/AnimatedSprite/hint_right"
onready var down_text = $"card/card/AnimatedSprite/hint_down"
onready var img_card = $"card/card/AnimatedSprite"
onready var life_point = $"life_point/Label"
onready var description = $"description"

var choices:Array

func updateState(pathNode):
	img_card.frames.clear("default")
	img_card.frames.add_frame("default", pathNode.img_res)
	
	life_point.text = str(Player.state.life)
	choices = pathNode.paths
	left_text.bbcode_text = pathNode.left_txt
	right_text.bbcode_text = pathNode.right_txt
	up_text.bbcode_text = pathNode.up_txt
	down_text.bbcode_text = pathNode.down_txt
	description.bbcode_text = ""
	yield(get_tree().create_timer(1.0), "timeout")
	description.bbcode_text = pathNode.desc_text
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_card_choice_made(direction):
	if visible:
		GlobalPath.set_card(choices[direction])


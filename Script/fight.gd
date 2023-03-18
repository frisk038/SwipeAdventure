extends Node2D

onready var left_text = $"card/card/AnimatedSprite/hint_left"
onready var up_text = $"card/card/AnimatedSprite/hint_up"
onready var right_text = $"card/card/AnimatedSprite/hint_right"
onready var down_text = $"card/card/AnimatedSprite/hint_down"
onready var img_card = $"card/card/AnimatedSprite"

var choices:Array

func updateState(pathNode):
	choices = pathNode.paths
	
	img_card.frames.clear("default")
	img_card.frames.add_frame("default", pathNode.img_res)
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

func _on_card_choice_made(direction):
	pass

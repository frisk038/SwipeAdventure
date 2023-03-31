extends Control

onready var left_text = $"card_control/card/AnimatedSprite/hint_bg/hint_left"
onready var up_text = $"card_control/card/AnimatedSprite/hint_bg/hint_up"
onready var right_text = $"card_control/card/AnimatedSprite/hint_bg/hint_right"
onready var down_text = $"card_control/card/AnimatedSprite/hint_bg/hint_down"
onready var img_card = $"card_control/card/AnimatedSprite"
onready var life_point = $"stat_bg/HBoxContainer/life/life_point"
onready var food_point = $"stat_bg/HBoxContainer/food/food_point"
onready var money_point = $"stat_bg/HBoxContainer/money/money_point"
onready var description = $"texture_desc/description"
onready var location = $"card_control/card/location"
onready var card = $"card_control"

const TEXT_APPEARING_SPEED = 0.03 
var choices:Array
var lapsed = 0

func _physics_process(delta):
	lapsed += delta
	description.visible_characters = lapsed/TEXT_APPEARING_SPEED

func updateState(pathNode:GlobalPath.PathNode):
	_on_Player_player_updated()
	img_card.frames.clear("default")
	img_card.frames.add_frame("default", pathNode.img_res)
	
	life_point.text = str(Player.state.life)
	choices = pathNode.paths
	left_text.bbcode_text = pathNode.left_txt
	right_text.bbcode_text = pathNode.right_txt
	up_text.bbcode_text = pathNode.up_txt
	down_text.bbcode_text = pathNode.down_txt
	lapsed = 0
	description.visible_characters = 0
	location.text = pathNode.location
	card.call("reveal_next_card")
	description.bbcode_text = pathNode.desc_text
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	lapsed = 0
	var err = Player.connect("player_updated", self, "_on_Player_player_updated")
	if err != OK:
		print("cant connect player_updated signal !", err)

func _on_Player_player_updated():
	life_point.text = str(Player.state.life)
	food_point.text = str(Player.state.potion)
	money_point.text = str(Player.state.money)
	
func _on_card_control_choice_made(direction):
	if visible:
		GlobalPath.set_card(choices[direction])

func _on_food_pressed():
	if Player.state.potion > 0:
		Player.update_stats("potion", Player.state.potion - 1)
		Player.update_stats("life", Player.state.life+2)

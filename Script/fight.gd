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
var life:int
var atk:int
var first_turn:bool = true

func updateState(pathNode:GlobalPath.PathNode):
	choices = pathNode.paths
	
	img_card.frames.clear("default")
	img_card.frames.add_frame("default", pathNode.img_res)
	enemy_name.text = pathNode.vname
	enemy_dialog.bbcode_text = pathNode.desc_text
	enemy_life.text = str(pathNode.life)
	life = pathNode.life
	atk = pathNode.atk
	first_turn = true
	player_life.text = str(Player.state.life)
	player_mp.text = str(Player.state.mp)
	player_pn.text = str(Player.state.potion)
	
	left_text.bbcode_text = "[center]Atk Special[/center]"
	right_text.bbcode_text = "[center]Potion[/center]"
	up_text.bbcode_text = "[center]Atk[/center]"
	down_text.bbcode_text = "[center]Fuir[/center]"

func set_life(new_life:int):
	life = new_life
	if life <= 0:
		life = 0
		print("bravo")
	enemy_life.text = str(life)

func _ready():
	var err = Player.connect("player_updated", self, "_on_Player_player_updated")
	if err != OK:
		print("cant connect player_updated signal !", err)

func _process(delta):
	pass

func _on_Player_player_updated():
	player_life.text = str(Player.state.life)
	player_mp.text = str(Player.state.mp)
	player_pn.text = str(Player.state.potion)

func _on_card_choice_made(choice):
	if visible:
		var flee = false
		match choice:
			GlobalPath.LEFT:
				if Player.state.mp >= 1:
					Player.update_stats("mp", Player.state.mp - 1)
					set_life(life - Player.state.atk * 2) 
			GlobalPath.UP:
				set_life(life - Player.state.atk) 
			GlobalPath.RIGHT:
				if Player.state.potion > 0:
					Player.update_stats("potion", Player.state.potion - 1)
					Player.update_stats("life", Player.state.life+2)
			GlobalPath.DOWN:
				if randi() % 2:
					flee = true
		
		if !first_turn:
			Player.update_stats("life", Player.state.life - atk)
			print("enemy atk ", str(atk))
		
		if Player.state.life <= 0:
			GlobalPath.set_card(choices[GlobalPath.UP])
		elif life <= 0:
			GlobalPath.set_card(choices[GlobalPath.LEFT])
		elif flee:
			GlobalPath.set_card(choices[GlobalPath.RIGHT])
		first_turn = false
		

extends Node2D

onready var card = $"fight_card"
onready var left_text = $"fight_card/card/AnimatedSprite/hint_left"
onready var up_text = $"fight_card/card/AnimatedSprite/hint_up"
onready var right_text = $"fight_card/card/AnimatedSprite/hint_right"
onready var down_text = $"fight_card/card/AnimatedSprite/hint_down"
onready var img_card = $"fight_card/card/AnimatedSprite"
onready var enemy_name = $"enemy_layout/enemy_name"
onready var enemy_life = $"enemy_layout/enemy_lp/Label"
onready var enemy_dialog = $"dialogue"
onready var player_life = $"player_layout/player_lp/Label"
onready var player_mp = $"player_layout/player_mp/Label"
onready var player_pn = $"player_layout/player_pn/Label"
onready var anim_player = $"player_anim"
onready var anim_enemy = $"enemy_anim"
onready var player_layout = $"player_layout"

var choices:Array
var life:int
var atk:int
var flee_pending:bool = false
var flee_granted:bool = false

func updateState(pathNode:GlobalPath.PathNode):
	choices = pathNode.paths
	
	img_card.frames.clear("default")
	img_card.frames.add_frame("default", pathNode.img_res)
	enemy_name.text = pathNode.vname
	enemy_dialog.bbcode_text = pathNode.desc_text
	enemy_life.text = str(pathNode.life)
	life = pathNode.life
	atk = pathNode.atk
	flee_pending = false
	flee_granted = false
	player_life.text = str(Player.state.life)
	player_mp.text = str(Player.state.mp)
	player_pn.text = str(Player.state.potion)
	player_layout.position = Vector2.ZERO
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

func check_end() -> bool:
	if flee_granted:
		GlobalPath.set_card(choices[GlobalPath.RIGHT])
		return true
	elif Player.state.life <= 0:
		GlobalPath.set_card(choices[GlobalPath.UP])
		return true
	elif life <= 0:
		GlobalPath.set_card(choices[GlobalPath.LEFT])
		return true
	return false

func _ready():
	var err = Player.connect("player_updated", self, "_on_Player_player_updated")
	if err != OK:
		print("cant connect player_updated signal !", err)

func _on_Player_player_updated():
	player_life.text = str(Player.state.life)
	player_mp.text = str(Player.state.mp)
	player_pn.text = str(Player.state.potion)

func _on_fight_card_choice_made(choice):
	match choice:
		GlobalPath.LEFT:
			if Player.state.mp >= 1:
				anim_player.play("enemy_shake")
				Player.update_stats("mp", Player.state.mp - 1)
				set_life(life - Player.state.atk * 2) 
		GlobalPath.UP:
			anim_player.play("enemy_shake")
			set_life(life - Player.state.atk) 
		GlobalPath.RIGHT:
			if Player.state.potion > 0:
				Player.update_stats("potion", Player.state.potion - 1)
				Player.update_stats("life", Player.state.life+2)
				anim_player.play("player_heal")
		GlobalPath.DOWN:
			if randi() % 2:
				flee_pending = true
				anim_player.play("player_prep_flee")
			else:
				anim_player.play("player_not_flee")

func _on_player_anim_animation_finished(_anim_name):
	if check_end():
		return

	card.set_process_input(false)
	Player.update_stats("life", Player.state.life - atk)
	anim_enemy.play("atk")
	
func _on_enemy_anim_animation_finished(_anim_name):
	card.set_process_input(true)
	if check_end():
		return
	
	if flee_pending:
		flee_granted = true
		flee_pending = false
		anim_player.play("player_flee")




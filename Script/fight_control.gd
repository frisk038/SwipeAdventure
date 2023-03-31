extends Control

onready var card = $"fight_card/card"
onready var fcard = $"fight_card"
onready var left_text = $"fight_card/card/AnimatedSprite/hint_bg/hint_left"
onready var up_text = $"fight_card/card/AnimatedSprite/hint_bg/hint_up"
onready var right_text = $"fight_card/card/AnimatedSprite/hint_bg/hint_right"
onready var down_text = $"fight_card/card/AnimatedSprite/hint_bg/hint_down"
onready var img_card = $"fight_card/card/AnimatedSprite"
onready var enemy_name = $"fight_card/card/name"
onready var enemy_life = $"life_bg/enemy_layout/lp"
onready var enemy_dialog = $"dialog_bg/dialog"
onready var player_life = $"stat_bg/player_layout/life/lp"
onready var player_mp = $"stat_bg/player_layout/mp_atk/mp"
onready var player_pn = $"stat_bg/player_layout/food/fp"
onready var player_layout = $"stat_bg/player_layout"
onready var enemy_layout = $"life_bg/enemy_layout"

signal fight_end

var choices:Array
var life:int
var atk:int
var flee_pending:bool = false
var flee_granted:bool = false
var flee_tween:Tween

func new_timestamp():
	var tick = OS.get_ticks_msec()
	var ms = str(tick)
	ms.erase(ms.length() - 1, 1)
	var timestamp = str(tick/3600000)+":"+str(tick/60000).pad_zeros(2)+":"+str(tick/1000).pad_zeros(2)+"."+ms+"\t"
	return timestamp

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
	player_layout.rect_position = Vector2(25, 21.5)
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

func animate_hit(obj:Control, vec:Vector2):
	var start_pos = obj.rect_position
	var tween := create_tween()
	tween.tween_property(obj, "rect_position", start_pos+vec, 0.2)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_IN_OUT)
	yield(tween, "finished")
	tween = create_tween()
	tween.tween_property(obj, "rect_position", start_pos, 0.2)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(obj, "modulate:a", 0, 0.3)
	yield(tween, "finished")
	tween = create_tween()
	tween.tween_property(obj, "modulate:a", 1, 0.5)
	yield(tween, "finished")

func animate_buf(obj:Control):
	var scale = obj.rect_scale
	var tween := create_tween()
	tween.tween_property(obj, "rect_scale", Vector2(1.1, 1.1), 0.3)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_IN_OUT)
	yield(tween, "finished")
	
	tween = create_tween()
	tween.tween_property(obj, "rect_scale", scale, 0.2)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_IN_OUT)
	yield(tween, "finished")

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
		GlobalPath.UP:
			yield(animate_hit(enemy_layout, Vector2(0, -30)), "completed")
			set_life(life - Player.state.atk)
		GlobalPath.LEFT:
			if Player.state.mp >= 1:
				Player.update_stats("mp", Player.state.mp - 1)
				yield(animate_hit(enemy_layout, Vector2(0, -30)), "completed")
				set_life(life - Player.state.atk * 2)
			else: return
		GlobalPath.RIGHT:
			if Player.state.potion > 0:
				Player.update_stats("potion", Player.state.potion - 1)
				yield(animate_buf(player_layout), "completed")
				Player.update_stats("life", Player.state.life+2)
			else: return
		GlobalPath.DOWN:
			if randi() % 2:
				flee_pending = true
				var tween = create_tween()
				tween.tween_property(player_layout, "modulate:a", 0.5, 0.5)
				yield(tween, "finished")
			else:
				var tween = create_tween()
				tween.tween_property(player_layout, "modulate", Color("ff0000"), 0.3)
				yield(tween, "finished")
				tween = create_tween()
				tween.tween_property(player_layout, "modulate", Color("ffffff"), 0.5)
				yield(tween, "finished")
	player_turn_end()

func player_turn_end():
	fcard.set_process_input(false)
	if life <= 0:
		emit_signal("fight_end", GlobalPath.LEFT)
	else:
		var tween := create_tween()
		var start_pos = card.rect_position
		tween.tween_property(card, "rect_position", start_pos+Vector2(0, 50), 0.2)\
			.set_trans(Tween.TRANS_ELASTIC)\
			.set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(card, "rect_rotation", 10, 0.2)\
			.set_trans(Tween.TRANS_ELASTIC)\
			.set_ease(Tween.EASE_IN_OUT)
		yield(tween, "finished")
		tween = create_tween()
		tween.tween_property(card, "rect_position", start_pos, 0.2)\
			.set_trans(Tween.TRANS_ELASTIC)\
			.set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(card, "rect_rotation", 0, 0.2)\
			.set_trans(Tween.TRANS_ELASTIC)\
			.set_ease(Tween.EASE_IN_OUT)
		yield(animate_hit(player_layout, Vector2(0, 20)), "completed")
		Player.update_stats("life", Player.state.life - atk)
		if Player.state.life <= 0:
			emit_signal("fight_end", GlobalPath.UP)
#			GlobalPath.set_card(choices[GlobalPath.UP])
	if flee_pending :
		var start_pos = player_layout.rect_position
		var tween = create_tween()
		tween.tween_property(player_layout, "rect_position", start_pos+Vector2(0, 150), 3)\
			.set_trans(Tween.TRANS_ELASTIC)\
			.set_ease(Tween.EASE_IN_OUT)
		yield(tween, "finished")
		player_layout.rect_position = start_pos
		emit_signal("fight_end", GlobalPath.RIGHT)
#		GlobalPath.set_card(choices[GlobalPath.RIGHT])
		return
	fcard.set_process_input(true)

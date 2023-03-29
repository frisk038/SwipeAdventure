extends Control

const DETECTION_TRESHOLD = 60

onready var card:Panel = $"card"
onready var back:Panel = $"back"
onready var hint_left = $"card/AnimatedSprite/hint_bg/hint_left"
onready var hint_up = $"card/AnimatedSprite/hint_bg/hint_up"
onready var hint_right = $"card/AnimatedSprite/hint_bg/hint_right"
onready var hint_down = $"card/AnimatedSprite/hint_bg/hint_down"
onready var hint_up_bg = $"card/AnimatedSprite/hint_bg"

var drag_start_pos:Vector2
var is_dragging:bool

signal choice_made

func on_click_release(evt_position:Vector2):
	hide_hint()
	
	var vec = evt_position - drag_start_pos
	if vec.length() < DETECTION_TRESHOLD:
		var tween := create_tween()
		tween.tween_property(card, "rect_position", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(card, "rect_rotation", 0.0, 0.2).set_ease(Tween.EASE_IN_OUT)
		return
		
	var choice = vector_to_choice(vec)
	var goto = 0.0
	var property = ""
	match choice:
		GlobalPath.RIGHT:
			goto = +500
			property = "rect_position:x"
		GlobalPath.LEFT:
			goto = -500
			property = "rect_position:x"
		GlobalPath.UP:
			goto = -800
			property = "rect_position:y"
		GlobalPath.DOWN:
			goto = 800
			property = "rect_position:y"
	var tween := create_tween()
	tween.tween_property(card, property, goto, 0.2).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(self, "_on_animation_finished", [choice])

func show_hint(choice:int):
	hide_hint()
	hint_up_bg.visible = true
	match choice:
		GlobalPath.RIGHT:
			hint_right.visible=true
		GlobalPath.LEFT:
			hint_left.visible=true
		GlobalPath.DOWN:
			hint_down.visible=true
		GlobalPath.UP:
			hint_up.visible=true

func hide_hint():
	hint_right.visible = false
	hint_left.visible = false
	hint_down.visible = false
	hint_up.visible = false
	hint_up_bg.modulate.a = 0

func on_clicking(event:InputEventScreenTouch):
	if event.is_pressed() && card.get_rect().has_point(get_local_mouse_position()):
		drag_start_pos = event.position
		is_dragging = true
	elif event.pressed == false:
		is_dragging = false
		on_click_release(event.position)

func on_dragging(evt_position:Vector2):
		var hint_visible_dist = 60
		var pos = (evt_position - drag_start_pos).limit_length(50)
		var choice = vector_to_choice(pos)
		
		card.rect_position = pos
		show_hint(choice)
		var move = pos.y
		if choice == GlobalPath.LEFT || choice == GlobalPath.RIGHT:
			move = pos.x
		
		card.rect_rotation =  -move * 0.050
		hint_up_bg.modulate = lerp(Color("#00ffffff"), Color("#ffffffff"), 
			abs(move)/hint_visible_dist)

func vector_to_choice(vec:Vector2):
	var absVec = vec.abs()
	if absVec.x > absVec.y:
		if vec.x > 0 :
			return GlobalPath.RIGHT
		else:
			return GlobalPath.LEFT
	else:
		if vec.y > 0 :
			return GlobalPath.DOWN
		else:
			return GlobalPath.UP

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventScreenTouch:
		on_clicking(event)
	elif is_dragging && event is InputEventScreenDrag:
		on_dragging(event.position)

func _on_animation_finished(choice):
	# back scale down 
	var tween := create_tween()
	tween.tween_property(back, "rect_scale:x", 0.1, 0.2).set_ease(Tween.EASE_IN_OUT)
	yield(tween, "finished")
	emit_signal("choice_made", choice)
	# reset back and card
	back.visible = false
	card.rect_position = Vector2.ZERO
	card.rect_rotation = 0.0
	card.rect_scale.x = 0.1
	# car scale up
	tween = create_tween()
	tween.tween_property(card, "rect_scale:x", 1, 0.2).set_ease(Tween.EASE_IN_OUT)
	yield(tween, "finished")
	# hide back behind card
	back.visible = true
	back.rect_position = Vector2.ZERO
	back.rect_scale.x = 1


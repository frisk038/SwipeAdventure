extends Node2D

const DETECTION_TRESHOLD = 100

onready var card:Panel = $"card"
onready var anim_player = $"AnimationPlayer"
onready var hint_left = $"card/AnimatedSprite/hint_left"
onready var hint_up = $"card/AnimatedSprite/hint_up"
onready var hint_right = $"card/AnimatedSprite/hint_right"
onready var hint_down = $"card/AnimatedSprite/hint_down"
onready var hint_up_bg = $"card/AnimatedSprite/hint_bg"
onready var tween = $"Tween"

var drag_start_pos:Vector2
var is_dragging:bool
var previous_direction:int

signal choice_made

func reset_card():
	card.rect_position = Vector2.ZERO
	card.rect_rotation = 0.0
	card.rect_scale.x = -0.1
	card.visible = false

func get_choice(evt_position:Vector2):
	var choice = vector_to_choice(evt_position)
	match choice:
		GlobalPath.RIGHT:
			anim_player.play("right")
		GlobalPath.LEFT:
			anim_player.play("left")
		GlobalPath.DOWN:
			anim_player.play("down")
		GlobalPath.UP:
			anim_player.play("up")

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
	hint_up_bg.visible = false
	hint_right.visible = false
	hint_left.visible = false
	hint_down.visible = false
	hint_up.visible = false

func on_clicking(event:InputEventScreenTouch):
	if event.is_pressed() :
		drag_start_pos = event.position
		is_dragging = true
	elif event.pressed == false:
		hide_hint()
		is_dragging = false
		get_choice(event.position)
			
func on_dragging(evt_position:Vector2):
	var choice = vector_to_choice(evt_position)
	if choice == -1 :
		hide_hint()
		previous_direction = -1
		return
	if previous_direction != choice:
		previous_direction = choice
		show_hint(choice)

func vector_to_choice(vec:Vector2):
	var drag_direction:Vector2 = vec - drag_start_pos
	if drag_direction.length() < DETECTION_TRESHOLD:
		return -1
	var absVec = drag_direction.abs()
	if absVec.x > absVec.y:
		if drag_direction.x > 0 :
			return GlobalPath.RIGHT
		else:
			return GlobalPath.LEFT
	else:
		if drag_direction.y > 0 :
			return GlobalPath.DOWN
		else:
			return GlobalPath.UP

func _ready():
	reset_card()
	anim_player.play("reveal")
	set_process_input(true)

func _input(event):
	if anim_player.is_playing():
		return
	if event is InputEventScreenTouch :
		on_clicking(event)
	elif is_dragging && event is InputEventScreenDrag:
		on_dragging(event.position)

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name != "reveal" && !("_drag" in anim_name) ):
		reset_card()
		anim_player.play("reveal")
		
	match anim_name:
		"right":
			emit_signal("choice_made", GlobalPath.RIGHT)
		"left":
			emit_signal("choice_made", GlobalPath.LEFT)
		"down":
			emit_signal("choice_made", GlobalPath.DOWN)
		"up":
			emit_signal("choice_made", GlobalPath.UP)

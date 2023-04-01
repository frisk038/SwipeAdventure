extends "card.gd"

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
	yield(tween, "finished")
	emit_signal("choice_made", choice)

func reveal_next_card():
	card.visible = false
	var tween := create_tween()
	tween.tween_property(back, "rect_scale:x", 0.1, 0.2).set_ease(Tween.EASE_IN_OUT)
	yield(tween, "finished")
	back.visible = false
	card.rect_position = Vector2.ZERO
	card.rect_rotation = 0.0
	card.rect_scale.x = 0.1
	card.visible = true
	tween = create_tween()
	tween.tween_property(card, "rect_scale:x", 1, 0.2).set_ease(Tween.EASE_IN_OUT)
	yield(tween, "finished")
	# hide back behind card
	back.visible = true
	back.rect_position = Vector2.ZERO
	back.rect_scale.x = 1

extends "card.gd"

func on_click_release(evt_position:Vector2):
	hide_hint()

	var vec = evt_position - drag_start_pos
	var tween := create_tween()
	tween.tween_property(card, "rect_position", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(card, "rect_rotation", 0.0, 0.2).set_ease(Tween.EASE_IN_OUT)
	var choice = vector_to_choice(vec)
	if vec.length() > DETECTION_TRESHOLD:
		yield(tween, "finished")
		emit_signal("choice_made", choice)



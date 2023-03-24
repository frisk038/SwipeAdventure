tool
extends Control

signal value_updated
signal select_relative_property
signal confirmed
signal finished

enum TYPES {
	INT = TYPE_INT,
	REAL = TYPE_REAL,
	VECTOR2 = TYPE_VECTOR2,
	VECTOR3 = TYPE_VECTOR3,
	STRING = TYPE_STRING
}

onready var _current_value: Button = find_node("CurrentValue")
onready var _custom_value: HBoxContainer = find_node('CustomValue')
onready var _delete_button: Button = find_node('DeleteButton')
onready var _relative_selector: Button = find_node('RelativeSelectorButton')

export (String) var label = 'current value' setget set_label
export (TYPES) var type = TYPES.INT setget set_type
export (bool) var can_clear_custom_value := true setget set_can_clear_custom_value
export (bool) var show_relative_selector := true setget set_show_relative_selector
export (bool) var can_edit_value := true setget set_can_edit_value
export (bool) var show_confirm_button := false setget set_show_confirm_button
export (bool) var disabled := false setget set_disabled
export (bool) var transparent := false setget set_transparent
export (Color) var font_color := Color.white setget set_font_color

const MIN_SIZE := 30.0

var _input_visible: Control
var _relative_source: Button
var _should_return_null_value := true

func _ready():
	if _input_visible == null:
		_on_ClearButton_pressed()

	var relative_buttons := [
		$CustomValue/RelativeSelectorButton,
		$CustomValue/Vector2/X/RelativeVector2X,
		$CustomValue/Vector2/Y/RelativeVector2Y,
		$CustomValue/Rect2/X/RelativeRect2X,
		$CustomValue/Rect2/Y/RelativeRect2Y,
		$CustomValue/Rect2/H/RelativeRect2H,
		$CustomValue/Rect2/W/RelativeRect2W,
	]

	for button in relative_buttons:
		if not button.is_connected("pressed", self, "_on_RelativeSelectorButton_pressed"):
			button.connect("pressed", self, "_on_RelativeSelectorButton_pressed", [button])

	set_label(label)
	set_type(type)
	set_show_relative_selector(show_relative_selector)
	set_can_clear_custom_value(can_clear_custom_value)
	set_disabled(disabled)
	set_show_confirm_button(show_confirm_button)
	
	_on_PropertyFromTo_item_rect_changed()

func set_type(the_type: int) -> void:
	type = the_type

	var node_name: String = 'FreeText'
	var custom_value = find_node('CustomValue')

	if custom_value == null:
		return

	for child in custom_value.get_children():
		if child is Button:
			continue

		child.hide()

	var show_global_relative := true

	match type:
		TYPE_VECTOR2:
			node_name = 'Vector2'
			show_global_relative = false
		TYPE_VECTOR3:
			node_name = 'Vector3'
			show_global_relative = false
		TYPE_RECT2:
			node_name = "Rect2"
			show_global_relative = false
		_:
			node_name = 'FreeText'

	if _relative_selector == null:
		_relative_selector = find_node('RelativeSelectorButton')

	_relative_selector.visible = show_global_relative

	_input_visible = find_node(node_name)
	_input_visible.show()

func set_can_clear_custom_value(can_clear: bool) -> void:
	can_clear_custom_value = can_clear

	var clear_button = find_node('ClearButton')
	clear_button.visible = can_clear_custom_value

func set_can_edit_value(can_edit: bool) -> void:
	can_edit_value = can_edit

func _animate_custom_value(mode: int, signal_to_emit = null) -> AnimaNode:
	if _input_visible == null:
		return

	if _custom_value == null:
		_custom_value = find_node('CustomValue')

	_should_return_null_value = false

	var anima := $AnimaNode
	anima.clear()
	anima.set_default_duration(0.3)
	anima.set_apply_initial_values(AnimaTween.PLAY_MODE.NORMAL)

	anima.then(
		Anima.Node(_current_value) \
			.anima_scale(Vector2(0.5, 0.5)) \
			.anima_from(Vector2.ONE) \
			.anima_easing(ANIMA.EASING.EASE_OUT_BACK)
	)
	anima.with(
		Anima.Node(_current_value).anima_fade_out()
	)
	anima.with(
		Anima.Node(_custom_value) \
			.anima_scale(Vector2.ONE) \
			.anima_from(Vector2(1.5, 1.5)) \
			.anima_easing(ANIMA.EASING.EASE_OUT_BACK) \
			.anima_on_started(self, '_handle_custom_value_visibility', true, false) \
			.anima_initial_value(Vector2(1.5, 1.5))
	)
	anima.with(
		Anima.Node(_custom_value).anima_fade_in().anima_initial_value(0.0)
	)

	var height: float = max(38, _input_visible.rect_size.y)

	anima.with(
		Anima.Node(self) \
			.anima_property("min_size:y") \
			.anima_to(height)
	)
	anima.with(
		Anima.Node(self) \
			.anima_property("size:y") \
			.anima_to(height)
	)

	_custom_value.show()
	_custom_value.rect_size.y = height

	if mode == AnimaTween.PLAY_MODE.NORMAL:
		anima.play()
		
		yield(anima, "animation_completed")

		if is_inside_tree() and _input_visible.is_visible_in_tree():
			_grab_focus(_input_visible)
	else:
		anima.play_backwards()

		_should_return_null_value = true

	if signal_to_emit != null:
		emit_signal(signal_to_emit)

	return anima

func _grab_focus(node: Node) -> void:
	if not node is LineEdit:
		node = node.find_next_valid_focus()

	if node:
		node.grab_focus()

func clear_value() -> void:
	_on_ClearButton_pressed()

func set_placeholder(value) -> void:
	if _input_visible == null or value == null:
		return

	var t = typeof(value)
	if t == TYPE_VECTOR2 or t == TYPE_VECTOR3:
		var fields = ['x', 'y'] if t == TYPE_VECTOR2 else ['x', 'y', 'z']
		
		for field in fields:
			var l: LineEdit = _input_visible.find_node(field)
			var label: Label = l.get_parent().find_node("Label")
			var v: String = str(value[field])

			l.placeholder_text = v
			label.hint_tooltip = "Current value: " + v
	elif typeof(value) == TYPE_RECT2:
		var fields = ['x', 'y', 'w', 'h']
		
		for field in fields:
			var l: LineEdit = _input_visible.find_node(field)
			var label: Label = l.get_parent().find_node("Label")
			var v: String = ""
			
			if field == "x" or field == "y":
				v = str(value.position[field])
			elif field == "w":
				v = str(value.size.x)
			elif field == "h":
				v = str(value.size.y)

			l.placeholder_text = v
			label.hint_tooltip = "Current value: " + v
	else:
		_input_visible.placeholder_text = str(value)

func set_calculated_value(value) -> void:
	pass

func set_initial_value(value) -> void:
	set_value(value, null, false)

func set_value(value, calculated_value = null, animate := true) -> void:
	if value == null or _input_visible == null:
		return

	if _input_visible is LineEdit:
		var s: String = str(value)

		if _input_visible.has_method('set_value'):
			_input_visible.set_value(s)
		else:
			_input_visible.text = s

	elif _input_visible.name == 'Vector2':
		var x: LineEdit = _input_visible.find_node('x')
		var y: LineEdit = _input_visible.find_node('y')

		if value is Array:
			x.text = str(value[0])
			y.text = str(value[1])

		if calculated_value:
			x.hint_tooltip = str(calculated_value.x)
			y.hint_tooltip = str(calculated_value.y)
	elif _input_visible.name == 'Vector3':
		var x: LineEdit = _input_visible.find_node('x')
		var y: LineEdit = _input_visible.find_node('y')
		var z: LineEdit = _input_visible.find_node('z')

		if value is Array:
			x.text = str(value[0])
			y.text = str(value[1])
			z.text = str(value[2])
	elif _input_visible.name == 'Rect2':
		var x: LineEdit = _input_visible.find_node('x')
		var y: LineEdit = _input_visible.find_node('y')
		var w: LineEdit = _input_visible.find_node('w')
		var h: LineEdit = _input_visible.find_node('h')

		if value is Array:
			x.text = str(value[0])
			y.text = str(value[1])
			w.text = str(value[2])
			h.text = str(value[3])

	if animate:
		_on_CurrentValue_pressed()

func set_relative_value(value: String) -> void:
	if _input_visible is LineEdit:
		_input_visible.text = value

	var linked_node: LineEdit = _relative_source.get_node(_relative_source.linked_field)

	if linked_node.text:
		linked_node.text = linked_node.text + value
	else:
		linked_node.text = value

	emit_signal("value_updated")

func get_value():
	if _input_visible == null or _should_return_null_value:
		return null

	if _input_visible is LineEdit:
		if _input_visible.has_method('get_value'):
			return _input_visible.get_value()
		
		return _input_visible.text
	elif _input_visible.name == 'Vector2':
		var x: LineEdit = _input_visible.find_node('x')
		var y: LineEdit = _input_visible.find_node('y')

		return [x.get_value(), y.get_value()]
	elif _input_visible.name == 'Vector3':
		var x: LineEdit = _input_visible.find_node('x')
		var y: LineEdit = _input_visible.find_node('y')
		var z: LineEdit = _input_visible.find_node('z')

		return [x.get_value(), y.get_value(), z.get_value()]
	elif _input_visible.name == 'Rect2':
		var x: LineEdit = _input_visible.find_node('x')
		var y: LineEdit = _input_visible.find_node('y')
		var w: LineEdit = _input_visible.find_node('w')
		var h: LineEdit = _input_visible.find_node('h')

		return [x.get_value(), y.get_value(), w.get_value(), h.get_value()]

func set_label(new_label: String) -> void:
	label = new_label

	if not _current_value:
		_current_value = find_node("CurrentValue")

	_current_value.set_text(label)

func get_label() -> String:
	return _current_value.text

func set_show_relative_selector(relative_button: bool) -> void:
	show_relative_selector = relative_button
	
	var button: Button = find_node("RelativeSelectorButton")
	button.visible = show_relative_selector

func _on_CurrentValue_pressed():
	if not can_edit_value:
		return

	_animate_custom_value(AnimaTween.PLAY_MODE.NORMAL)

func _on_ClearButton_pressed():
	_animate_custom_value(AnimaTween.PLAY_MODE.BACKWARDS, "value_updated")

func _on_input_changed() -> void:
	emit_signal('value_updated')

func _on_FreeText_text_changed(_new_text):
	emit_signal("value_updated")

func _handle_custom_value_visibility(visible: bool) -> void:
	_custom_value.visible = visible

func _on_RelativeSelectorButton_pressed(source: Button):
	_relative_source = source

	emit_signal("select_relative_property")

func set_disabled(is_disabled: bool) -> void:
	disabled = is_disabled

	_current_value.disabled = is_disabled

func set_show_confirm_button(show: bool) -> void:
	show_confirm_button = show
	$CustomValue/ConfirmButton.visible = show

func _on_CurrentValue_item_rect_changed():
	if _current_value.rect_size.y > rect_size.y:
		rect_min_size.y = _current_value.rect_size.y

func _on_PropertyFromTo_item_rect_changed():
	$CustomValue.rect_min_size.x = 0
	$CustomValue.rect_size.x = rect_size.x

	rect_size.x = max($CustomValue.rect_size.x, rect_size.x)

	$HBoxContainer.rect_size.x = rect_size.x

func _on_ConfirmButton_pressed():
	var label = get_value()

	if label:
		_current_value.set_text(label)

	_on_ClearButton_pressed()

	emit_signal("confirmed")

func _on_CurrentValueBorderless_pressed():
	_on_CurrentValue_pressed()

func set_transparent(t: bool) -> void:
	transparent = t

	if transparent:
		$HBoxContainer/CurrentValue.add_stylebox_override("normal", StyleBoxEmpty.new())
	else:
		$HBoxContainer/CurrentValue.remove_stylebox_override("normal")

func set_font_color(c: Color) -> void:
	font_color = c

	$HBoxContainer/CurrentValue.add_color_override("font_color", font_color)

func _on_CustomValue_item_rect_changed():
	$HBoxContainer.rect_size.x = $CustomValue.rect_size.x

tool
extends VBoxContainer

const SINGLE_ANIMATION = preload("res://addons/anima/visual-editor/editor/AnimaSingleAnimationData.tscn")

signal select_animation
signal select_easing
signal select_relative_property
signal updated
signal removed
signal highlight_nodes(nodes)
signal select_node_property(node_path)
signal preview_animation(preview_info)

onready var _title = find_node("Title")
onready var _node_or_group = find_node("NodeOrGroup")
onready var _group_data = find_node("GroupData")
onready var _grid_data = find_node("GridData")
onready var _animations_container = find_node("AnimationsContainer")
onready var _animation_group_type = find_node("AnimationGroupType")
onready var _animation_grid_type = find_node("AnimationGridType")
onready var _animation_type_icon = find_node("AnimationTypeIcon")
onready var _background_rect = find_node("Background")
onready var _distance_formula = find_node("DistanceFormula")

onready var _duration = find_node("Duration")
onready var _delay = find_node("Delay")
onready var _timer = find_node("Timer")

var _path: String
var _source_node: Node
var _relative_source: Node
var _animate_as: int = AnimaVisualNode.ANIMATE_AS.NODE
var _is_restoring := false
var _source_instance: Node
var _is_playing := false

func _ready():
	margin_right = 0

	_node_or_group.hide()
	_group_data.hide()
	_grid_data.hide()

func _enter_tree():
	_populate_combos()

func _populate_combos() -> void:
	if _distance_formula == null:
		_distance_formula = find_node("DistanceFormula")
		_animation_group_type = find_node("AnimationGroupType")
		_animation_grid_type = find_node("AnimationGridType")

	_populate_combo(_distance_formula, ANIMA.DISTANCE.keys())
	_populate_combo(_animation_group_type, ANIMA.GROUP.keys())
	_populate_combo(_animation_grid_type, ANIMA.GRID.keys())

func _populate_combo(node: OptionButton, options: Array) -> void:
	node.clear()

	for option in options:
		var s: String = option
		node.add_item(s.replace("_", " ").capitalize())

func show_group_or_node() -> void:
	_node_or_group.show()

func set_data(node: Node, path: String, toggle_title := true):
	_title.set_text("./" + path)

	_path = path
	_source_node = node

	var animate_as = find_node("AnimateAs")
	animate_as.visible = node.get_child_count() > 1
	animate_as.get_parent().rect_size.x = 0

	if toggle_title:
		_maybe_toggle_title()

func _maybe_toggle_title() -> void:
	_title.pressed = _animations_container.get_child_count() == 0

func get_data() -> Dictionary:
	if _animations_container == null:
		_animations_container = find_node("AnimationsContainer")

	var animations := []

	for child in _animations_container.get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			animations.push_back(child.get_data())

	var data :=  {
		node_path = _path,
		duration = _duration.get_value(),
		delay = _delay.get_value(),
		animate_as = _animate_as,
		animations = animations,
		group = {
			items_delay = float(_group_data.find_node("ItemsDelay").get_value()),
			animation_type = _animation_group_type.get_selected_id(),
			start_index = int(_group_data.find_node("StartIndex").get_value())
		},
		grid = {
			size = Vector2(_grid_data.find_node("x").get_value(), _grid_data.find_node("y").get_value()),
			items_delay = float(_grid_data.find_node("ItemsDelay").get_value()),
			animation_type = _animation_grid_type.get_selected_id(),
			start_point = Vector2(_grid_data.find_node("pointX").get_value(), _grid_data.find_node("pointY").get_value()),
			formula = _distance_formula.get_selected_id(),
		},
	}

	return data

func restore_data(data: Dictionary) -> void:
	_is_restoring = true

	var button = _node_or_group.find_node("GridContainer").get_child(data.animate_as)
	button.pressed = true
	find_node("AnimateAs").icon = button.icon

	find_node("Duration").set_value(data.duration)
	find_node("Delay").set_value(data.delay)

	if data.has("group"):
		_group_data.find_node("ItemsDelay").set_value(data.group.items_delay)
		_group_data.find_node("StartIndex").set_value(data.group.start_index)

		var type = data.group.animation_type
		for index in _animation_group_type.get_item_count():
			var item_id = _animation_group_type.get_item_id(index)

			if item_id == data.group.animation_type:
				_animation_group_type.select(index)

				break

		_on_AnimationType_item_selected(data.group.animation_type)

	if data.has("grid"):
		var size = data.grid.size

		_grid_data.find_node("ItemsDelay").set_value(data.grid.items_delay)
		_grid_data.find_node("pointX").set_value(data.grid.start_point.x)
		_grid_data.find_node("pointY").set_value(data.grid.start_point.y)
		_grid_data.find_node("x").set_value(size.x)
		_grid_data.find_node("y").set_value(size.y)

		_animation_grid_type.select(data.grid.animation_type)
		_on_AnimationGridType_item_selected(data.grid.animation_type)

		_distance_formula.select(data.grid.formula)

	if data.has("animations"):
		for animation_id in data.animations.size():
			var animation = data.animations[animation_id]
			var item = _on_AddAnimation_pressed()

			animation.node = _source_node
			animation._root_node = data._root_node
			item.set_meta("_data_index", animation_id)
			item.restore_data(animation)

	_maybe_toggle_title()
	_maybe_show_group_data()

	_is_restoring = false

func set_relative_property(node_path: String, property: String) -> void:
	_relative_source.set_relative_value(node_path + ":" + property)

func _press_button_in_group(group: ButtonGroup, selected_button: int) -> void:
	var buttons = group.get_buttons()

	buttons[selected_button].set_pressed(true)

func _on_UseAnimation_pressed():
	emit_signal("updated")

func _on_PropertyButton_pressed():
	emit_signal("select_property")

func _on_AnimaAnimationData_mouse_entered():
	if _source_node == null and Engine.editor_hint:
		printerr("_on_AnimaAnimationData_mouse_entered: _source_node is null")

		return

	emit_signal("highlight_nodes", [_source_node])

func _on_Title_toggled(button_pressed):
	$Content.visible = button_pressed

	var icon: String = "res://addons/anima/icons/Minus.svg"

	if not button_pressed:
		icon = "res://addons/anima/icons/Add.svg"

	$Title.set_icon(load(icon))

func _on_RemoveButton_pressed():
	emit_signal("removed", self)

func _on_AnimateProperty_pressed():
	emit_signal("updated")

func _on_SelectAnimation_pressed():
	emit_signal("select_animation")

func _on_Duration_value_updated():
	emit_signal("updated")

func _on_Delay_value_updated():
	emit_signal("updated")

func _emit_updated():
	emit_signal("updated")

func _maybe_show_group_data() -> void:
	var animate_as_group: ButtonGroup = _node_or_group.find_node("AsNode").group
	var selected_button = animate_as_group.get_pressed_button()
	var selected_button_index = selected_button.get_index()

	if _group_data == null:
		_group_data = find_node("GroupData")
		_grid_data = find_node("GridData")

	_grid_data.visible = selected_button_index == AnimaVisualNode.ANIMATE_AS.GRID
	_group_data.visible = selected_button_index == AnimaVisualNode.ANIMATE_AS.GROUP
	find_node("AnimateAs").icon = selected_button.icon

	_animate_as = selected_button_index

	if _is_restoring:
		return

	emit_signal("updated")

func _on_Title_mouse_entered():
	_on_AnimaAnimationData_mouse_entered()

func _update_me():
	emit_signal("updated")

func _on_AnimationType_item_selected(index: int):
	_group_data.find_node("StartIndex").visible = index == ANIMA.GROUP.FROM_INDEX
	_group_data.find_node("ItemsDelay").visible = index != ANIMA.GROUP.TOGETHER
	_group_data.find_node("LabelItemsDelay").visible = index != ANIMA.GROUP.TOGETHER

	_emit_updated()

func _on_AnimationGridType_item_selected(index):
	_grid_data.find_node("StartPoint").visible = index == ANIMA.GRID.FROM_POINT
	_grid_data.find_node("Vector2").visible = index == ANIMA.GRID.FROM_POINT
	_grid_data.find_node("ItemsDelay").visible = index != ANIMA.GROUP.TOGETHER
	_grid_data.find_node("LabelItemsDelay").visible = index != ANIMA.GROUP.TOGETHER

	_emit_updated()


func _on_AnimaAnimationData_item_rect_changed():
	if _background_rect:
		_background_rect.rect_size = rect_size

	if not _title:
		_title = find_node("Title")

	_title.find_node("ActionsContainer").rect_size.x = rect_size.x

func _on_PropertyFromTo_value_updated():
	_emit_updated()

func _on_Button_pressed():
	var size := Vector2.ZERO

	if _source_node is GridContainer:
		size.y = max(1, _source_node.columns)
	else:
		size.y = 1

	size.x = floor(_source_node.get_child_count() / size.y)

	_grid_data.find_node("x").set_value(size.x)
	_grid_data.find_node("y").set_value(size.y)

	_emit_updated()

func _on_AddAnimation_pressed():
	var instance = SINGLE_ANIMATION.instance()

	instance.connect("select_property_to_animate", self, "_on_select_property_to_animate", [instance])
	instance.connect("updated", self, "_emit_updated")
	instance.connect("select_relative_property", self, "_on_select_relative_property")
	instance.connect("select_easing", self, "_on_select_easing", [instance])
	instance.connect("select_animation", self, "_on_select_animation", [instance])
	instance.connect("preview_animation", self, "_on_single_animation_preview")
	instance.set_meta("_data_index", _animations_container.get_child_count())

	_animations_container.add_child(instance)

	if not _is_restoring:
		emit_signal("updated")

	return instance

func _on_Time_toggled(button_pressed):
	find_node("TimeContent").visible = button_pressed

	if button_pressed:
		_title.pressed = true

func _on_AnimateAs_toggled(button_pressed):
	find_node("NodeOrGroup").visible = button_pressed

	if button_pressed:
		_title.pressed = true

func _on_Remove_pressed():
	$ConfirmationDialog.popup_centered()

func _on_select_property_to_animate(source: Node) -> void:
	emit_signal("select_node_property", source, _source_node.get_path())

func _on_ConfirmationDialog_confirmed():
	queue_free()

	emit_signal("updated")

func _on_select_relative_property(source_from_to: Node) -> void:
	_relative_source = source_from_to

	emit_signal("select_relative_property")

func _on_select_easing(source_instance: Node) -> void:
	_source_instance = source_instance

	emit_signal("select_easing")

func set_easing(name: String, value: int) -> void:
	_source_instance.set_easing(name, value)

func _on_select_animation(source: Node) -> void:
	_source_instance = source

	emit_signal("select_animation")

func selected_animation(label: String, name: String) -> void:
	_source_instance.selected_animation(name)

func _get_data_index() -> int:
	return get_meta("_data_index")

func _on_single_animation_preview(preview_data: Dictionary) -> void:
	preview_data.animation_data_id = _get_data_index()

	emit_signal("preview_animation", preview_data)

func _on_OptionButton_item_selected(id):
	if id == 0:
		_on_Time_toggled(true)
	else:
		_on_Remove_pressed()

func _on_Preview_play_preview():
	var preview_data = {
		animation_data_id = _get_data_index(),
		preview_button = find_node("Preview")
	}

	emit_signal("preview_animation", preview_data)

tool
extends Node

enum PIVOT {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	CENTER_LEFT,
	CENTER,
	CENTER_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT
}

enum VISIBILITY {
	IGNORE,
	HIDDEN_ONLY,
	TRANSPARENT_ONLY,
	HIDDEN_AND_TRANSPARENT
}

enum GRID {
	TOGETHER,
	SEQUENCE_TOP_LEFT,
	SEQUENCE_BOTTOM_RIGHT,
	COLUMNS_ODD,
	COLUMNS_EVEN,
	ROWS_ODD,
	ROWS_EVEN,
	ODD_ITEMS,
	EVEN_ITEMS,
	FROM_CENTER,
	FROM_POINT,
	RANDOM
}

enum DISTANCE {
	EUCLIDIAN,
	MANHATTAN,
	CHEBYSHEV,
	COLUMN,
	ROW,
	DIAGONAL,
}

const GROUP := {
	FROM_TOP = GRID.SEQUENCE_TOP_LEFT,
	FROM_BOTTOM = GRID.SEQUENCE_BOTTOM_RIGHT,
	FROM_CENTER = GRID.FROM_CENTER,
	ODDS_ONLY = GRID.COLUMNS_ODD,
	EVEN_ONLY = GRID.COLUMNS_EVEN,
	RANDOM = GRID.RANDOM,
	TOGETHER = GRID.TOGETHER,
	FROM_INDEX = GRID.FROM_POINT
}

enum TYPE {
	NODE,
	GROUP,
	GRID
}

enum VALUES_IN {
	PIXELS,
	PERCENTAGE
}

const Align = {
	LEFT = HALIGN_LEFT,
	CENTER = HALIGN_CENTER,
	RIGHT = HALIGN_RIGHT,
}

const VAlign = {
	TOP = VALIGN_TOP,
	CENTER = VALIGN_CENTER,
	BOTTOM = VALIGN_BOTTOM,
}

enum RELATIVE_TO {
	INITIAL_VALUE,
	PREVIOUS_FRAME,
}

enum APPLY_INITIAL_VALUES {
	ON_ANIMATION_CREATION,
	ON_PLAY
}

const EASING = AnimaEasing.EASING

const DEFAULT_DURATION := 0.7
const DEFAULT_ITEMS_DELAY := 0.05
const MINIMUM_DURATION := 0.000001

const _FRAME_COLORS := [
	Color("#8B008B"),
	Color("#4B0082"),
	Color("#9400D3"),
	Color("#7b4747"),
	Color("#6B8E23"),
	Color("#2E8B57"),
	Color("#3CB371"),
	Color("#20B2AA"),
	Color("#006400"),
	Color("#00008B"),
]

var _custom_animations := {}
var _animations_list := []

func get_animations_list() -> Array:
	return _animations_list

func set_animations_list(new_list: Array) -> void:
	_animations_list = new_list

func get_custom_animations() -> Dictionary:
	return _custom_animations

func add_custom_animation(name: String, frames: Dictionary) -> void:
	_custom_animations[name] = frames

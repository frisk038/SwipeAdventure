extends Node

const LEFT = 0
const UP = 1
const RIGHT = 2
const DOWN = 3
const NONE = -1

signal new_path

var game_path:Dictionary

class PathNode:
	var img_res
	var desc_text=""
	var paths=[0,0,0,0]
	var special=""
	var life=0
	var atk=0
	var vname=""
	var left_txt=""
	var up_txt=""
	var right_txt=""
	var down_txt=""
	var location=""

	func _init(a, d, p, s, l, k, n, lt, ut, rt, dt, loc):
		img_res = a
		desc_text = d
		paths = p
		special = s
		life = l
		atk = k
		vname = n
		left_txt = lt
		up_txt = ut
		right_txt = rt
		down_txt = dt
		location = loc


func path_to_string(path:int)-> String:
	match path:
		LEFT:
			return "left"
		UP:
			return "up"
		RIGHT:
			return "right"
		DOWN:
			return "down"
		_:
			return ""

func fill_path(json):
	for jpath in json:
		var path = PathNode.new(load(jpath["asset"]), 
		jpath["desc"], jpath["path"], jpath["type"], jpath["enemy_life"], 
		jpath["enemy_atk"], jpath["enemy_name"], jpath["left_text"], jpath["up_text"],
		jpath["right_text"], jpath["down_text"], jpath["location"])
		game_path[int(jpath["index"])] = path



func set_card(card):
	Player.state.card = card
	emit_signal("new_path")
	
func _ready():
	var file = File.new()
	var err = file.open("res://Assets/JSON/path.json", File.READ)
	if err != OK:
		print("failed to load path.json file !")
		return
	var content = file.get_as_text()
	file.close()
	var json = parse_json(content)
	fill_path(json)


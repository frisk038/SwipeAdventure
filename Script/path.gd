extends Node

const LEFT = 0
const UP = 1
const RIGHT = 2
const DOWN = 3

signal new_path

var game_path:Array

class PathNode:
	var img_res
	var desc_text=""
	var paths=[0,0,0,0]
	var special=""
	var life=0
	var atk=0
	var avatar
	var vname=""
	var left_txt=""
	var up_txt=""
	var right_txt=""
	var down_txt=""
	
	func _init(a, d, p, s, l, k, n, lt, ut, rt, dt):
		img_res = a
		desc_text = d
		paths = p
		special = s
		life = l
		atk = k
		vname = n
		left_txt=lt
		up_txt=ut
		right_txt=rt
		down_txt=dt


func fill_path(json):
	for jpath in json:
		var path = PathNode.new(load(jpath["a"]), 
		jpath["d"], jpath["p"], jpath["s"], jpath["l"], 
		jpath["k"], jpath["n"], jpath["lt"], jpath["ut"],
		jpath["rt"], jpath["dt"])
		if path.special=="Fight":
			path.avatar = load(jpath["v"])
		game_path.append(path)

func set_card(card):
	Player.state.card = card
	emit_signal("new_path")
	
func _ready():
	var file = File.new()
	var err = file.open("res://Assets/Json/path.json", File.READ)
	if err != OK:
		print("failed to load path.json file !")

	var content = file.get_as_text()
	file.close()
	var json = parse_json(content)
	fill_path(json)


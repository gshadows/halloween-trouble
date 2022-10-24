extends Node

const MENU_SCENE = "res://ui/Menu.tscn"
const GAME_SCENE_TEMPLATE = "res://levels/level-"

const Menu = preload(MENU_SCENE)
var menu_node = null
var level_node = null


func _ready():
	randomize()
	open_menu()


func quit_game():
	get_tree().quit(0)


func new_game():
	open_level("01");


func open_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	unload_level()
	menu_node = Menu.instance()
	menu_node.connect("quit", self, "quit_game")
	menu_node.connect("start", self, "new_game")
	add_child(menu_node)


func open_level(level):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	unload_menu()
	level_node = load(GAME_SCENE_TEMPLATE + level + ".tscn").instance()
	level_node.connect("quit", self, "open_menu")
	add_child(level_node)


func unload_level():
	if level_node != null:
		remove_child(level_node)
		level_node.queue_free()
		level_node = null

func unload_menu():
	if menu_node != null:
		remove_child(menu_node)
		menu_node.queue_free()
		menu_node = null

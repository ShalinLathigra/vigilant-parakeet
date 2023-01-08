extends Node2D

var MAIN_SCENE_PATH: String = "res://Scenes/main.tscn"
var MAIN_MENU_PATH: String = "res://addons/EasyMenus/Scenes/main_menu.tscn"

func _ready() -> void:
	EventBus.start_game_pressed.connect(change_scene.bind(MAIN_SCENE_PATH))
	EventBus.back_to_main_pressed.connect(change_scene.bind(MAIN_MENU_PATH))

func change_scene(path: StringName) -> void:
	get_tree().change_scene_to_file(path)

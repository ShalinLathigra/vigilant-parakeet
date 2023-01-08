extends Node
@export var pause_menu: CanvasLayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_menu.open_pause_menu()

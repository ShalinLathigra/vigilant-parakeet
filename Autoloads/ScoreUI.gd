extends CanvasLayer

@export var p1_blackout: VictoryRect
@export var p2_blackout: VictoryRect
@export var main_menu: Button
@export var quit: Button
@export var end_label: Label

var delta_label: Label
var p1_score: Label
var p2_score: Label
var rally_counter: Label

const MAX_SCALE_INCREASE = 1.25
const RALLIES_TO_MAX_SCALE = 27.0

func _ready() -> void:
	p1_score = $"ScoreUI/P1Score" as Label
	p2_score = $"ScoreUI/P2Score" as Label
	rally_counter = $"ScoreUI/Rally Counter" as Label

	State.rally_changed.connect(_on_rally_changed)
	State.score_changed.connect(_on_score_changed)

func _on_rally_changed(rally: int) -> void:
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	var to_scale = 1 + MAX_SCALE_INCREASE * min(rally / RALLIES_TO_MAX_SCALE, 1)
	tw.tween_property(rally_counter, "scale", Vector2(to_scale, to_scale), 0.2)
	tw.tween_property(rally_counter, "scale", Vector2.ONE, 0.5)

	rally_counter.text = "{rally}".format({"rally": rally})


func _on_score_changed(score: int, is_player_one: bool) -> void:
	var tw = create_tween() \
			.set_parallel() \
			.set_trans(Tween.TRANS_CUBIC) \
			.set_ease(Tween.EASE_IN_OUT)
	var target_label: Label = p1_score if is_player_one else p2_score
	var to_scale = 1 + MAX_SCALE_INCREASE
	var rally_origin: Vector2 = rally_counter.position

	# tween it towards the target
	tw.tween_property(rally_counter, "position", target_label.position, 0.75)
	# fade it out when getting near
	tw.tween_property(rally_counter, "self_modulate:a", 0, 0.15).set_delay(0.6)
	# after this finishes, get the target score to inflate like above.
	tw.chain().tween_property(target_label, "scale", Vector2(to_scale, to_scale), 0.2)
	tw.tween_callback(func (): target_label.text = "{score}".format({"score": score})).set_delay(0.1)
	tw.chain().tween_property(target_label, "scale", Vector2.ONE, 0.5)
	tw.tween_callback(func (): EventBus.rally_reset.emit())
	tw.tween_property(rally_counter, "position", rally_origin, 0.25)
	tw.chain().tween_property(rally_counter, "self_modulate:a", 1, 0.25)

	await tw.finished

	if State.check_finished():
		_handle_game_over()

func _handle_game_over() -> void:
	var p1_victory: bool = State.check_p1_victory()
	var victory_rect: VictoryRect = p1_blackout if p1_victory else p2_blackout
	end_label.visible_characters = 0
	end_label.text = "Congratulations {Player}, you have won your home a great boon" \
		.format({"Player": "P1" if p1_victory else "P2"})
	end_label.show()
	var max_characters = end_label.text.length()
	victory_rect.activate(2)

	var tw = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(rally_counter, "self_modulate:a", 0, 2)
	tw.tween_callback(func(): rally_counter.hide())

	await victory_rect.finished
	await tw.finished
	tw = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(end_label, "visible_characters", max_characters, 3)
	tw.tween_callback(func(): main_menu.show())
	tw.tween_callback(func(): quit.show())
	tw.tween_property(main_menu, "self_modulate:a", 1, 2)
	tw.parallel().tween_property(quit, "self_modulate:a", 1, 2)

func refresh() -> void:
	rally_counter.visible_characters = -1
	rally_counter.self_modulate.a = 1
	rally_counter.show()

	end_label.visible_characters = 0
	end_label.self_modulate.a = 1
	end_label.hide()

	main_menu.self_modulate.a = 0
	main_menu.hide()

	quit.self_modulate.a = 0
	quit.hide()

	p1_blackout.reset()
	p2_blackout.reset()

	p1_score.text = "0"
	p2_score.text = "0"

func _on_main_menu_pressed() -> void:
	EventBus.back_to_main_pressed.emit()
	refresh()

func _on_quit_pressed() -> void:
	get_tree().quit()

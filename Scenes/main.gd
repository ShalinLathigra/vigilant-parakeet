extends Node2D

const MSEC_TO_START_OPTION = 3000
var p1_ready: bool
var p2_ready: bool
var round_active: bool
var p1_paddle: Paddle
var p2_paddle: Paddle
var minotaur: Minotaur
var barriers: Node2D
var time_of_start_option: int

var h1_tween: Tween
var h2_tween: Tween

var game_over: bool


@export var p1_highlight: Sprite2D
@export var p2_highlight: Sprite2D
@export var p1_start: Label
@export var p2_start: Label

func _ready() -> void:
	ScoreUI.show()
	p1_paddle = get_node("Paddle") as Paddle
	p2_paddle = get_node("Paddle2") as Paddle
	minotaur = get_node("Minotaur") as Minotaur
	EventBus.rally_reset.connect(_handle_rally_end)
	p1_paddle.reset()
	p2_paddle.reset()
	minotaur.reset()
	p1_highlight.self_modulate = Color(1,1,1,0)
	p2_highlight.self_modulate = Color(1,1,1,0)
	time_of_start_option = Time.get_ticks_msec() + MSEC_TO_START_OPTION
	State.reset()

func _exit_tree() -> void:
	if not game_over:
		ScoreUI.hide()

func _input(event: InputEvent) -> void:
	if round_active: return
	if Time.get_ticks_msec() < time_of_start_option: return
	if event.is_action_pressed("p1_bash") and not p1_ready:
		p1_ready = true
		h1_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		h1_tween.tween_property(p1_highlight, "self_modulate:a", 1, 0.75)
		p1_start.hide()
	if event.is_action_pressed("p2_bash") and not p2_ready:
		p2_ready = true
		h2_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		h2_tween.tween_property(p2_highlight, "self_modulate:a", 1, 0.75)
		p2_start.hide()

	if p1_ready and p2_ready:
		round_active = true
		if h1_tween.is_running(): await h1_tween.finished
		if h2_tween.is_running(): await h2_tween.finished
		h1_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		h1_tween.tween_property(p1_highlight, "self_modulate:a", 0, 0.5)
		h2_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		h2_tween.tween_property(p2_highlight, "self_modulate:a", 0, 0.5)
		p1_paddle.activate()
		p2_paddle.activate()
		await get_tree().create_timer(1).timeout
		minotaur.activate()

func _handle_rally_end() -> void:
	time_of_start_option = Time.get_ticks_msec() + MSEC_TO_START_OPTION
	round_active = false
	p1_ready = false
	p2_ready = false
	p1_paddle.reset()
	p2_paddle.reset()
	minotaur.reset()
	p1_start.show()
	p2_start.show()


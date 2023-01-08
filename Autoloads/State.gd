extends Node

const POINTS_PER_RALLY = 5
const WIN_POINTS = 50

signal rally_changed(rally: int)
signal score_changed(score: int, is_player_one: bool)

var rally: int :
	get:
		return rally
	set(value):
		rally = value
		rally_changed.emit(rally)

var p1_score: int
var p2_score: int

func _ready() -> void:
	EventBus.minotaur_bounced.connect(_handle_minotaur_bounced)
	EventBus.minotaur_reached_goal.connect(_handle_point_scored)
	EventBus.rally_reset.connect(_handle_rally_reset)

func _handle_minotaur_bounced() -> void:
	rally += 1

func _handle_point_scored(player_one_scored: bool) -> void:
	if player_one_scored:
		p1_score += rally + POINTS_PER_RALLY
		score_changed.emit(p1_score, true)
	else:
		p2_score += rally + POINTS_PER_RALLY
		score_changed.emit(p2_score, false)

func _handle_rally_reset() -> void:
	rally = 0

func reset() -> void:
	rally = 0
	p1_score = 0
	p2_score = 0

func check_finished() -> bool:
	return p1_score >= WIN_POINTS or p2_score > WIN_POINTS

func check_p1_victory() -> bool:
	return p1_score >= WIN_POINTS

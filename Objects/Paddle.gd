class_name Paddle
extends CharacterBody2D

const SPEED = 50.0
const SPARTAN_SIZE = 12.0
const P1_PREFIX = "p1"
const P2_PREFIX = "p2"

const BASH_SUFFIX = "_bash"
const DOWN_SUFFIX = "_down"
const UP_SUFFIX = "_up"
const RIGHT_SUFFIX = "_right"
const LEFT_SUFFIX = "_left"

@export_range(1, 10, 1) var start_size: int = 1
@export_range(0, 2500, 50) var ticks_to_next_bash: int
@export_range(0, 1000, 50) var max_ticks_to_early_bash_exit: int
@export var is_player_one: bool = true
@export var marker: Marker2D
@export var topLeft: Marker2D
@export var botRight: Marker2D

var bash_action: StringName
var down_action: StringName
var up_action: StringName
var right_action: StringName
var left_action: StringName

var tick_of_next_bash: int

var body_shape: CollisionShape2D
var spartan_detector: BounceDetector
var shield: Shield
var hit_particles: CPUParticles2D
var size: int
var speed_mod: float = 1
var active: bool

func _ready() -> void:
	bash_action = (P1_PREFIX if is_player_one else P2_PREFIX) + BASH_SUFFIX
	down_action = (P1_PREFIX if is_player_one else P2_PREFIX) + DOWN_SUFFIX
	up_action = (P1_PREFIX if is_player_one else P2_PREFIX) + UP_SUFFIX
	right_action = (P1_PREFIX if is_player_one else P2_PREFIX) + RIGHT_SUFFIX
	left_action = (P1_PREFIX if is_player_one else P2_PREFIX) + LEFT_SUFFIX

	spartan_detector = get_node("SpartanDetector") as BounceDetector
	shield = get_node("Shield") as Shield
	body_shape = get_node("CollisionShape2D") as CollisionShape2D
	hit_particles = get_node("CPUParticles2D") as CPUParticles2D

	# set up detector and shield sizing + directions
	spartan_detector.toggle(true)
	spartan_detector.flip(not is_player_one)
	shield.flip(not is_player_one)
	resize(start_size)

func resize(new_size: int) -> void:
	size = new_size
	var dims = Vector2(SPARTAN_SIZE, SPARTAN_SIZE * size)
	spartan_detector.resize(dims)
	body_shape.shape.size = Vector2(dims.x - 1, dims.y - 1 if dims.y > 2 else 0)
	shield.resize(dims)
	speed_mod = 1.0 if size <= 0 else (1 + (0.5 / size))

func _physics_process(delta: float) -> void:
	if not active: return
	if Time.get_ticks_msec() < tick_of_next_bash - max_ticks_to_early_bash_exit: return
	var direction: Vector2 = Vector2(
		Input.get_axis(left_action, right_action),
		Input.get_axis(up_action, down_action)
	)

	# direction correction
	if direction.x > 0 and position.x > botRight.position.x:
		position.x = botRight.position.x
		direction.x = min(direction.x, 0)
	elif direction.x < 0 and position.x < topLeft.position.x:
		position.x = topLeft.position.x
		direction.x = max(direction.x, 0)

	if direction.y > 0 and position.y + size * SPARTAN_SIZE / 2 > botRight.position.y:
		position.y = botRight.position.y - size * SPARTAN_SIZE / 2
		direction.y = min(direction.y, 0)
	elif direction.y < 0 and position.y - size * SPARTAN_SIZE / 2 < topLeft.position.y:
		position.y = topLeft.position.y + size * SPARTAN_SIZE / 2
		direction.y = max(direction.y, 0)

	velocity = direction * SPEED * speed_mod
	var _collision: KinematicCollision2D = move_and_collide(velocity * delta)

func _input(event: InputEvent) -> void:
	if not active: return
	if event.is_action_pressed(bash_action):
		var tick = Time.get_ticks_msec()
		if tick < tick_of_next_bash: return

		tick_of_next_bash = tick + ticks_to_next_bash
		shield.bash()

func activate() -> void:
	active = true

func reset() -> void:
	active = false
	# tween to origin position
	var tw = create_tween() \
		.set_parallel() \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "global_position", marker.global_position, 3.0)
	await tw.finished
	if start_size == size: return
	tw = create_tween().set_loops(start_size - size)
	tw.tween_callback(func (): resize(size + 1)).set_delay(0.25)
	await tw.finished

func _on_spartan_detector_body_entered(_body: Node2D) -> void:
	resize(size - 1)
	if size <= 0:
		var temp_position = global_position
		position = Vector2.UP * 2000
		hit_particles.global_position = Vector2(temp_position.x, _body.global_position.y)
	else:
		hit_particles.global_position.y = _body.global_position.y
	hit_particles.emitting = true



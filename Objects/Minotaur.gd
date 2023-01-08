class_name Minotaur extends CharacterBody2D

# when starting, base speed
const BASE_SPEED = 75.0
const SPEED_INCREMENT = 10.0
const TIME_TO_NEXT_COLLISION = 100
const BOUNCES_TO_NEXT_INCREMENT = 3
const SPEED_MULTIPLIER_SCALING = 0.1
const INCREMENTS_TO_FULL_RED = 10.0

@export var direction: Vector2
var active: bool
var num_bounces: int = 0
var num_increments: int = 0
var time_of_last_collision: int
var sprite: Sprite2D
var origin: Vector2
var sprite_tween: Tween

func _ready() -> void:
	origin = position
	sprite = $Minotaur as Sprite2D
	EventBus.minotaur_bounced.connect(_increment_speed)
	direction = direction.normalized()

func _physics_process(delta: float) -> void:
	if not active: return
	velocity = direction * BASE_SPEED * (1 + num_increments * SPEED_MULTIPLIER_SCALING)
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if not collision: return
	direction = direction.reflect(Vector2.from_angle(collision.get_angle()))

func _increment_speed() -> void:
	num_bounces += 1
	if num_bounces % BOUNCES_TO_NEXT_INCREMENT != 0: return
	num_increments += 1
	sprite.self_modulate = lerp(Color.WHITE, Color.RED, clamp(num_increments / INCREMENTS_TO_FULL_RED, 0, 1))

func reset() -> void:
	if sprite_tween: sprite_tween.stop()
	sprite.rotation_degrees = 0
	num_increments = 0
	num_bounces = 0
	position = origin
	direction.x *= -1
	active = false
	sprite.self_modulate = Color(1,1,1,0)

func activate() -> void:
	sprite_tween = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	sprite_tween.tween_property(sprite, "self_modulate:a", 1, 1)
	sprite_tween.tween_callback(func (): active = true)
	sprite_tween.tween_callback(_start_rotation_tween)

func _start_rotation_tween() -> void:
	sprite_tween = create_tween() \
		.set_loops() \
		.set_parallel() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	sprite_tween.tween_property(sprite, "position:y", 2, 0.2)
	sprite_tween.tween_property(sprite, "position:y", 0, 0.2).set_delay(0.2)
	sprite_tween.tween_property(sprite, "rotation_degrees", 6, 0.4)
	sprite_tween.chain().tween_property(sprite, "position:y", 2, 0.2)
	sprite_tween.tween_property(sprite, "position:y", 0, 0.2).set_delay(0.2)
	sprite_tween.tween_property(sprite, "rotation_degrees", -6, 0.4)

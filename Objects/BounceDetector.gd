class_name BounceDetector extends Area2D

@export var sprite: Sprite2D
@export var sprite_rotated: bool

var area_shape: RectangleShape2D
var origin_location: Vector2

func _ready() -> void:
	area_shape = (get_node("CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D

func _on_body_entered(_body: Node2D) -> void:
	EventBus.minotaur_bounced.emit()

func flip(flipped: bool) -> void:
	position = origin_location * (-1 if flipped else 1)
	if not sprite: return

	sprite.flip_h = flipped
	sprite.flip_v = flipped and sprite_rotated

func resize(size: Vector2) -> void:
	area_shape.size = size
	if not sprite: return

	if not sprite_rotated:
		sprite.region_rect.size = size
	else:
		sprite.region_rect.size = Vector2(size.y, size.x)

func toggle(state: bool) -> void:
	monitoring = state
	monitorable = state

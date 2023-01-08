class_name Shield extends StaticBody2D

@export var target: Marker2D

var body_shape: CapsuleShape2D
var TW: Tween
var base_target_offset: Vector2
var base_origin_offset: Vector2
var target_offset: Vector2
var origin_offset: Vector2
var shield_detector: BounceDetector


func _ready() -> void:
	shield_detector = get_node("ShieldDetector") as BounceDetector
	body_shape = (get_node("CollisionShape2D") as CollisionShape2D).shape as CapsuleShape2D
	base_target_offset = Vector2.ZERO if not target else target.position
	base_origin_offset = position
	target_offset = base_target_offset
	origin_offset = base_origin_offset

func flip(flipped: bool) -> void:
	target_offset = base_target_offset * (-1 if flipped else 1)
	origin_offset = base_origin_offset * (-1 if flipped else 1)
	position = origin_offset
	shield_detector.flip(flipped)

func resize(size: Vector2) -> void:
	shield_detector.resize(size)
	body_shape.height = size.y - (1 if size.y > 2 else 0)

func bash() -> void:
	if not target: return
	position = origin_offset
	TW = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	TW.tween_property(self, "position", target_offset, 0.15)
	TW.tween_property(self, "modulate:a", 1, 0.15)
	TW.chain().tween_property(self, "position", origin_offset, 0.4)
	TW.tween_property(self, "modulate:a", 0, 0.2)

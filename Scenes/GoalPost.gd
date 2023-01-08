extends Area2D

@export var is_player_one_side: bool

var particles: GPUParticles2D
var gradient: TextureRect

func _ready() -> void:
	particles = $GPUParticles2D2 as GPUParticles2D
	gradient = $TextureRect as TextureRect

func _on_body_entered(body: Node2D) -> void:
	if not body is Minotaur:
		return

	particles.emitting = true
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(gradient, "self_modulate:a", 1, 0.15)
	tw.chain().tween_property(gradient, "self_modulate:a", 0.5, 0.1)
	tw.chain().tween_property(gradient, "self_modulate:a", 0.7, 0.3)
	tw.tween_callback(func(): particles.emitting = false)
	tw.chain().tween_property(gradient, "self_modulate:a", 0.2, 0.4)
	tw.chain().tween_property(gradient, "self_modulate:a", 0.3, 0.1)
	tw.chain().tween_property(gradient, "self_modulate:a", 0, 0.5)

	EventBus.minotaur_reached_goal.emit(0 if is_player_one_side else 1)

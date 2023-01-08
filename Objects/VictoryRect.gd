class_name VictoryRect
extends TextureRect

signal finished
var mat: ShaderMaterial
var active: bool
var duration: float = 0
var elapsed: float = 0

func _ready() -> void:
	mat = material as ShaderMaterial

func activate(d: float) -> void:
	duration = d
	active = duration > 0

func reset() -> void:
	mat.set_shader_parameter("t", -0.01)
	active = false

func _process(delta: float) -> void:
	if not active: return
	elapsed += delta
	mat.set_shader_parameter("t", min(elapsed / duration, 1))

	if elapsed / duration >= 1:
		active = false
		finished.emit()

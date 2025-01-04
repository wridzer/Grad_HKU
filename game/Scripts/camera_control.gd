class_name CameraControl
extends Camera2D


@export var _default_initial_shake_strength: float = 8.0
@export var _shake_decay_rate: float = 15.0

var _shake_strength: float


func apply_shake(initial_shake_strength: float = _default_initial_shake_strength) -> void:
	_shake_strength = initial_shake_strength


func _process(delta: float) -> void:
	if !is_equal_approx(_shake_strength, 0):
		_shake_strength = lerpf(_shake_strength, 0, _shake_decay_rate * delta)
		offset = get_random_offset()


func get_random_offset() -> Vector2:
	return Vector2(
		randf_range(-_shake_strength, _shake_strength),
		randf_range(-_shake_strength, _shake_strength)
	)

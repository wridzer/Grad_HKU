class_name Arrow
extends Node2D


@onready var timer: Timer = $Timer
@onready var hitbox_component_arrow: HitboxComponent = $HitboxComponentArrow

const SPEED := 150.0
var mouse_position: Vector2
var direction: Vector2
var hit: bool


func _ready() -> void:
	look_at(mouse_position)
	timer.wait_time = 2 / SPEED


func _physics_process(delta: float) -> void:
	if !hit:
		global_position += direction * SPEED * delta


func _on_hitbox_component_arrow_body_entered(body: Node2D) -> void:
	await get_tree().physics_frame
	timer.start()


func _on_timer_timeout() -> void:
	hit = true


func _on_hurtbox_hit() -> void:
	queue_free()

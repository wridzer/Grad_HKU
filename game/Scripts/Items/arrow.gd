class_name Arrow
extends Node2D


@onready var start_timer: Timer = $StartTimer
@onready var stop_timer: Timer = $StopTimer
@onready var hitbox_component_arrow: HitboxComponent = $HitboxComponentArrow

const STARTING_DISTANCE := 2
const STOPPING_DISTANCE := 2
const SPEED := 150.0
var mouse_position: Vector2
var direction: Vector2
var hit: bool


func _ready() -> void:
	look_at(mouse_position)
	start_timer.wait_time = STARTING_DISTANCE / SPEED
	stop_timer.wait_time = STOPPING_DISTANCE / SPEED
	start_timer.start()


func _physics_process(delta: float) -> void:
	# Until hitting anything, move towards the predefined direction
	if !hit:
		global_position += direction * SPEED * delta


func _on_start_timer_timeout() -> void:
	hitbox_component_arrow.set_process_mode(Node.PROCESS_MODE_INHERIT)


func _on_hitbox_component_arrow_body_entered(_body: Node2D) -> void:
	stop_timer.start()


func _on_stop_timer_timeout() -> void:
	hit = true


func _on_hurtbox_hit() -> void:
	queue_free()

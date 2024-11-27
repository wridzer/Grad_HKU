class_name Arrow
extends Node2D


@onready var start_timer: Timer = $StartTimer
@onready var stop_timer: Timer = $StopTimer
@onready var hitbox_component_arrow: HitboxComponent = $HitboxComponentArrow
@onready var danger_area: Area2D = $DangerArea

const STARTING_DISTANCE: float = 2.0
const STOPPING_DISTANCE: float = 2.0
const SPEED: float = 120.0
var mouse_position: Vector2
var direction: Vector2
var hit: bool = false


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
	hitbox_component_arrow.set_process_mode(Node.PROCESS_MODE_DISABLED)
	danger_area.set_process_mode(Node.PROCESS_MODE_DISABLED)


func _on_hurtbox_hit() -> void:
	queue_free()

class_name Arrow
extends Node2D


const STARTING_DISTANCE: float = 2.0
const STOPPING_DISTANCE: float = 2.0
const SPEED: float = 120.0

var mouse_position: Vector2
var direction: Vector2
var _hit: bool = false

@onready var _start_timer: Timer = $StartTimer
@onready var _stop_timer: Timer = $StopTimer
@onready var _hitbox_component_arrow: HitboxComponent = $HitboxComponentArrow
@onready var _danger_area: Area2D = $DangerArea


func _ready() -> void:
	look_at(mouse_position)
	_start_timer.wait_time = STARTING_DISTANCE / SPEED
	_stop_timer.wait_time = STOPPING_DISTANCE / SPEED
	_start_timer.start()


func _physics_process(delta: float) -> void:
	# Until hitting anything, move towards the predefined direction
	if !_hit:
		global_position += direction * SPEED * delta

	
func _on_start_timer_timeout() -> void:
	_hitbox_component_arrow.set_process_mode(Node.PROCESS_MODE_INHERIT)


func _on_hitbox_component_arrow_body_entered(_body: Node2D) -> void:
	_stop_timer.start()


func _on_stop_timer_timeout() -> void:
	_hit = true
	_hitbox_component_arrow.set_process_mode(Node.PROCESS_MODE_DISABLED)
	_danger_area.set_process_mode(Node.PROCESS_MODE_DISABLED)


func _on_hurtbox_hit() -> void:
	queue_free()

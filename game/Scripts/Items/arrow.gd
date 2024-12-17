class_name Arrow
extends Node2D


@export var starting_distance: float = 2.0
@export var stopping_distance: float = 2.0
@export var speed: float = 120.0

var goal: Vector2
var direction: Vector2
var _hit: bool = false

@onready var _start_timer: Timer = $StartTimer
@onready var _stop_timer: Timer = $StopTimer
@onready var _hitbox_component_arrow: HitboxComponent = $HitboxComponentArrow
@onready var _danger_area: Area2D = $DangerArea


func _ready() -> void:
	look_at(goal)
	_start_timer.wait_time = starting_distance / speed
	_stop_timer.wait_time = stopping_distance / speed
	_start_timer.start()


func _physics_process(delta: float) -> void:
	# Until hitting anything, move towards the predefined direction
	if !_hit:
		global_position += direction * speed * delta

	
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

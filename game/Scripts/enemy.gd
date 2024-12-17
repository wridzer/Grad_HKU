class_name Enemy
extends CharacterBody2D


@export_range(1.0, 20.0) var min_chase_speed: float = 5.0
@export_range(15.0, 100.0) var max_chase_speed: float = 50.0
@export_range(1.0, 6.0) var steering_value: float = 1.4
@export_range(0.5, 1.0) var turning_smoothing_value: float = 0.7
@export_range(0.0, 1.0) var speed_smoothing_value: float = 0.3
@export_range(0.0, 2.0) var stop_time: float = 0.5

@onready var _health_component: HealthComponent = $HealthComponent
@onready var danger_sensor_component: DangerSensorComponent = $DangerSensorComponent
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	assert(max_chase_speed > min_chase_speed, "enemy max_chase_speed is not larger than min_chase_speed") 
	Blackboard.increment_data("enemies_alive", 1)
	_health_component.die.connect(die)
	_health_component.immune.connect(hit)
	_health_component._owner = "enemy"


func die() -> void:
	Blackboard.increment_data("enemies_killed", 1)
	Blackboard.increment_data("enemies_alive", -1)
	queue_free()


func hit(_immune: bool) -> void:
	Blackboard.increment_data("damage_done", 1)

class_name Enemy
extends CharacterBody2D


@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var danger_sensor_component: DangerSensorComponent = $DangerSensorComponent

@export_range(1.0, 20.0) var min_chase_speed: float = 5.0
@export_range(15.0, 100.0) var max_chase_speed: float = 50.0
@export_range(1.0, 6.0) var steering_value: float = 1.4
@export_range(0.5, 1) var turning_smoothing_value: float = 0.7
@export_range(0.0, 1) var speed_smoothing_value: float = 0.3


func _ready() -> void:
	assert(max_chase_speed > min_chase_speed, "enemy max_chase_speed is not larger than min_chase_speed") 
	if (Blackboard.get_data("enemies_alive")):
		Blackboard.add_data("enemies_alive", Blackboard.get_data("enemies_alive") + 1)
	else:
		Blackboard.add_data("enemies_alive", 1)
	health_component.die.connect(die)
	health_component.immune.connect(hit)


func die() -> void:
	if (Blackboard.get_data("enemies_killed")):
		Blackboard.add_data("enemies_killed", Blackboard.get_data("enemies_killed") + 1)
	else:
		Blackboard.add_data("enemies_killed", 1)
	Blackboard.add_data("enemies_alive", Blackboard.get_data("enemies_alive") - 1)
	queue_free()


func hit(_immune: bool) -> void:
	if (Blackboard.get_data("damage_done")):
		Blackboard.add_data("damage_done", Blackboard.get_data("damage_done") + 1)
	else:
		Blackboard.add_data("damage_done", 1)

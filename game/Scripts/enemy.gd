class_name Enemy
extends CharacterBody2D


@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var danger_sensor_component: DangerSensorComponent = $DangerSensorComponent

# MAX_INT32
var squared_distance: int = (1 << 31) - 1

func _ready() -> void:
	if (Blackboard.get_data("enemies_alive")):
		Blackboard.add_data("enemies_alive", Blackboard.get_data("enemies_alive") + 1)
	else:
		Blackboard.add_data("enemies_alive", 1)
	health_component.die.connect(die)
	health_component.hit.connect(hit)


func _process(delta: float) -> void:
	squared_distance = global_position.distance_squared_to(Player.instance.global_position);


func die() -> void:
	if (Blackboard.get_data("enemies_killed")):
		Blackboard.add_data("enemies_killed", Blackboard.get_data("enemies_killed") + 1)
	else:
		Blackboard.add_data("enemies_killed", 1)
	Blackboard.add_data("enemies_alive", Blackboard.get_data("enemies_alive") - 1)
	queue_free()


func hit() -> void:
	if (Blackboard.get_data("damage_done")):
		Blackboard.add_data("damage_done", Blackboard.get_data("damage_done") + 1)
	else:
		Blackboard.add_data("damage_done", 1)
	pass

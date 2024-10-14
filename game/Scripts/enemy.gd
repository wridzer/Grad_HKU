class_name Enemy
extends CharacterBody2D


@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var danger_sensor_component: DangerSensorComponent = $DangerSensorComponent

# MAX_INT32
var squared_distance: int = (1 << 31) - 1

func _ready() -> void:
	health_component.die.connect(die)
	health_component.hit.connect(hit)


func _process(delta: float) -> void:
	squared_distance = global_position.distance_squared_to(Player.instance.global_position);


func die() -> void:
	queue_free()


func hit() -> void:
	pass

class_name Enemy
extends CharacterBody2D


signal dead

@export_range(1.0, 20.0) var min_chase_speed: float = 4.0
@export_range(15.0, 100.0) var max_chase_speed: float = 80.0
@export_range(1.0, 6.0) var steering_value: float = 3.4
@export_range(0.5, 1.0) var turning_smoothing_value: float = 0.8
@export_range(0.0, 1.0) var speed_smoothing_value: float = 0.01
@export_range(0.0, 2.0) var stop_time: float = 0.5

@export_range(0.0, 5.0) var sword_stun_time: float = 0.2
@export_range(0.0, 5.0) var shield_stun_time: float = 2
@export_range(0.0, 5.0) var arrow_stun_time: float = 0
@export_range(-50.0, 100.0) var sword_knockback_speed: float = 10
@export_range(-50.0, 100.0) var shield_knockback_speed: float = 40
@export_range(-50.0, 100.0) var arrow_knockback_speed: float = -5

@onready var _health_component: HealthComponent = $HealthComponent
@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var danger_sensor_component: DangerSensorComponent = $DangerSensorComponent
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	assert(max_chase_speed > min_chase_speed, "enemy max_chase_speed is not larger than min_chase_speed")
	
	Blackboard.increment_data("enemies_alive", 1)
	
	_health_component.die.connect(die)
	_hurtbox_component.hurt.connect(hurt)


func immunity(immune: bool) -> void:
	if immune:
		_hitbox_component.set_process_mode(ProcessMode.PROCESS_MODE_DISABLED)
		_hurtbox_component.set_process_mode(ProcessMode.PROCESS_MODE_DISABLED)
	else:
		_hitbox_component.set_process_mode(ProcessMode.PROCESS_MODE_INHERIT)
		_hurtbox_component.set_process_mode(ProcessMode.PROCESS_MODE_INHERIT)


func die() -> void:
	Blackboard.increment_data("enemies_killed", 1)
	Blackboard.increment_data("enemies_alive", -1)
	dead.emit(self)
	queue_free()


func hurt(knockback_direction: Vector2, hitbox_type: HitboxComponent.HitboxType) -> void:
	match hitbox_type:
		HitboxComponent.HitboxType.SWORD:
			print("SWORD knockback")
			Blackboard.increment_data("sword_hit_enemy_amount", 1)
			velocity = knockback_direction * sword_knockback_speed
			
			if sword_stun_time > 0 && state_machine.current_state_type != EnemyState.state_type_to_int(EnemyState.StateType.STUNNED):
				state_machine.transition_to_next_state(EnemyState.state_type_to_int(EnemyState.StateType.STUNNED), {"stun_length": sword_stun_time})
		HitboxComponent.HitboxType.SHIELD:
			print("SHIELD knockback")
			Blackboard.increment_data("shield_hit_enemy_amount", 1)
			velocity = knockback_direction * shield_knockback_speed
			
			if shield_stun_time > 0 && state_machine.current_state_type != EnemyState.state_type_to_int(EnemyState.StateType.STUNNED):
				state_machine.transition_to_next_state(EnemyState.state_type_to_int(EnemyState.StateType.STUNNED), {"stun_length": shield_stun_time})
		HitboxComponent.HitboxType.ARROW:
			print("ARROW knockback")
			Blackboard.increment_data("arrow_hit_enemy_amount", 1)
			velocity = knockback_direction * arrow_knockback_speed
			
			if arrow_stun_time > 0 && state_machine.current_state_type != EnemyState.state_type_to_int(EnemyState.StateType.STUNNED):
				state_machine.transition_to_next_state(EnemyState.state_type_to_int(EnemyState.StateType.STUNNED), {"stun_length": arrow_stun_time})

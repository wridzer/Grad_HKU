@tool
class_name Enemy
extends CharacterBody2D


signal died

@export_range(1.0, 20.0) var min_chase_speed: float = 4.0
@export_range(15.0, 100.0) var max_chase_speed: float = 80.0
@export_range(1.0, 6.0) var steering_value: float = 3.4
@export_range(0.5, 1.0) var turning_smoothing_value: float = 0.8
@export_range(0.0, 1.0) var speed_smoothing_value: float = 0.01
@export_range(0.0, 2.0) var stop_time: float = 0.5
@export_range(5.0, 100.0) var _aggro_range: float = 50.0

@export_range(0.0, 5.0) var sword_stun_time: float = 0.4
@export_range(0.0, 5.0) var shield_stun_time: float = 3
@export_range(0.0, 5.0) var arrow_stun_time: float = 0.1
@export_range(-50.0, 100.0) var sword_knockback_speed: float = 13
@export_range(-50.0, 100.0) var shield_knockback_speed: float = 25
@export_range(-50.0, 100.0) var arrow_knockback_speed: float = -5

var aggro_range_squared: float = _aggro_range * _aggro_range

@onready var _health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var danger_sensor_component: DangerSensorComponent = $DangerSensorComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var stun_timer: Timer = $StunTimer


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	assert(max_chase_speed > min_chase_speed, "enemy max_chase_speed is not larger than min_chase_speed")
	
	Blackboard.increment_data("enemies_total", 1)
	
	_health_component.die.connect(die)
	hurtbox_component.hurt.connect(hurt)


func immunity(immune: bool) -> void:
	if immune:
		_hitbox_component.set_process_mode(ProcessMode.PROCESS_MODE_DISABLED)
		hurtbox_component.immune = true
	else:
		_hitbox_component.set_process_mode(ProcessMode.PROCESS_MODE_INHERIT)
		hurtbox_component.immune = false


func die() -> void:
	Blackboard.increment_data("enemies_killed", 1)
	Blackboard.increment_data("enemies_killed_last_room", 1)
	
	died.emit(self)
	queue_free()


func hurt(knockback_direction: Vector2, hitbox_type: HitboxComponent.HitboxType) -> void:
	match hitbox_type:
		HitboxComponent.HitboxType.SWORD:
			print("SWORD knockback")
			Blackboard.increment_data("sword_hit_enemy_amount", 1)
			velocity = velocity + knockback_direction * sword_knockback_speed
			
			if sword_stun_time > 0:
				stun_timer.start(sword_stun_time)
				if state_machine.current_state_type != EnemyState.state_type_to_int(EnemyState.StateType.STUNNED):
					state_machine.transition_to_next_state(EnemyState.state_type_to_int(EnemyState.StateType.STUNNED))
		HitboxComponent.HitboxType.SHIELD:
			print("SHIELD knockback")
			Blackboard.increment_data("shield_hit_enemy_amount", 1)
			velocity = velocity + knockback_direction * shield_knockback_speed
			
			if shield_stun_time > 0:
				stun_timer.start(shield_stun_time)
				if state_machine.current_state_type != EnemyState.state_type_to_int(EnemyState.StateType.STUNNED):
					state_machine.transition_to_next_state(EnemyState.state_type_to_int(EnemyState.StateType.STUNNED))
		HitboxComponent.HitboxType.ARROW:
			print("ARROW knockback")
			Blackboard.increment_data("arrow_hit_enemy_amount", 1)
			velocity = velocity + knockback_direction * arrow_knockback_speed
			
			if arrow_stun_time > 0:
				stun_timer.start(arrow_stun_time) 
				if state_machine.current_state_type != EnemyState.state_type_to_int(EnemyState.StateType.STUNNED):
					state_machine.transition_to_next_state(EnemyState.state_type_to_int(EnemyState.StateType.STUNNED))

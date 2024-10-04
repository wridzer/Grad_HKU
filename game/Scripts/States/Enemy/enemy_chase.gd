class_name EnemyChase
extends EnemyState


const STATE_TYPE = StateType.CHASE
const CHASE_SPEED: float = 200.0
const STEERING_VALUE: float = 2.0
var directions: PackedVector2Array = [Vector2(1,0),Vector2(1,1),Vector2(0,1),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1)]
var context_map: PackedFloat32Array = [0,0,0,0,0,0,0,0]


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	enemy.set_velocity(Vector2.ZERO)
	super.enter(previous_state, data)


func update(_delta: float) -> void:
	if enemy.global_position.distance_to(Player.instance.global_position) > 50:
		finished.emit(state_type_to_int(StateType.IDLE))


func physics_update(delta: float) -> void:
	# Reset the context map
	context_map = [0,0,0,0,0,0,0,0]
	
	var player_direction = Player.instance.global_position - enemy.global_position.normalized()
	
	var best_direction = 0
	for i in directions.size():
		print("Vector2("+str(directions[i].x)+","+str(directions[i].y)+") is dot: " + str(directions[i].dot(player_direction)))
		var interest = directions[i].dot(player_direction)
		context_map[i] = interest - enemy.danger_sensor_component.danger_array[i]
		if i != 0 && context_map[i] > context_map[best_direction]:
			best_direction = i
	
	var steering_force = directions[best_direction] - enemy.get_velocity()
	steering_force *= STEERING_VALUE
	enemy.set_velocity(steering_force * CHASE_SPEED * delta)
	super.physics_update(delta)


func exit() -> void:
	super.exit()

class_name DangerSensorComponent
extends Node


static var directions: PackedVector2Array = [Vector2(1,0),Vector2(1,-1),Vector2(0,-1),Vector2(-1,-1),Vector2(-1,0),Vector2(-1,1),Vector2(0,1),Vector2(1,1)]

@export var _danger_value: float = 5.0
@export var _danger_secondary_value: float = 2.0
@export var _raycasts: Array[RayCast2D]

var danger_array: Array


func _physics_process(_delta: float) -> void:
	# Reset the danger array each frame
	danger_array = [0,0,0,0,0,0,0,0]
	
	for raycast: RayCast2D in _raycasts:
		if raycast.is_colliding():
			# Using the name as an int deprecates a separate iterator variable
			var i: int = raycast.get_name().to_int()
			
			# Get the next and previous item with modulo (-1 works fine though)
			var prev: int = i - 1
			var next: int = (i + 1) % _raycasts.size()
			
			# Set the danger values
			danger_array[i] = _danger_value
			danger_array[prev] = max(danger_array[prev], _danger_secondary_value)
			danger_array[next] = max(danger_array[next], _danger_secondary_value)

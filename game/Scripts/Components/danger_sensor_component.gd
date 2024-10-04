class_name DangerSensorComponent
extends Node


@export var danger_value: float = 5.0
@export var danger_secondary_value: float = 2.0
@export var raycasts: Array[RayCast2D]

var danger_array: Array
var lastEditedRaycast: int


func _physics_process(_delta: float) -> void:
	# Reset the danger array each frame
	danger_array = [0,0,0,0,0,0,0,0]
	
	for raycast: RayCast2D in raycasts:
		if raycast.is_colliding():
			# Using the name as an int deprecates a separate iterator variable
			var i: int = raycast.get_name().to_int()
			
			# Get the next and previous item with modulo (-1 works fine though)
			var prev: int = i - 1
			var next: int = (i + 1) % raycasts.size()
			
			# Set the danger values
			danger_array[i] = danger_value
			danger_array[prev] = max(danger_array[prev], danger_secondary_value)
			danger_array[next] = max(danger_array[next], danger_secondary_value)

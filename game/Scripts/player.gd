extends CharacterBody2D

const SPEED = 4000.0


func _ready() -> void:
	game_manager.connect("spawn_player", spawn.bind())


func _physics_process(delta: float) -> void:
	var directionx := Input.get_axis("move_left", "move_right")
	var directiony := Input.get_axis("move_up", "move_down")
	var direction = Vector2(directionx, directiony)
	
	velocity = direction * SPEED * delta if direction != Vector2.ZERO else velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()


func spawn(new_pos : Vector2):
	self.position = new_pos

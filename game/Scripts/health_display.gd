extends Node2D


@export var _health_component: HealthComponent
@export_range(400, 1000) var _offset: int = 500

var _health_sprites: Array[Sprite2D]
var _current_offset

@onready var _health_sprite: Sprite2D = $HealthSprite


func _ready() -> void:
	assert(is_instance_valid(_health_component), "Please assign a valid _health_component to HealthDisplay")
	await _health_component.ready
	_current_offset = _offset
	_health_sprites.append(_health_sprite)
	update_health()
	
	_health_component.health_gained.connect(update_health)
	_health_component.immunity.connect(func(immune): if immune: update_health())


func update_health() -> void:
	while _health_sprites.size() < _health_component.health:
		var new_sprite: Sprite2D = _health_sprite.duplicate()
		self.add_child(new_sprite)
		new_sprite.position.x += _current_offset
		_current_offset += _offset
		_health_sprites.append(new_sprite)
	
	while _health_sprites.size() > _health_component.health:
		_current_offset -= _offset
		var old_sprite: Sprite2D = _health_sprites.pop_back()
		old_sprite.queue_free()

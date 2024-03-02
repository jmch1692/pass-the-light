extends CharacterBody2D

@export var speed: int = 80
@onready var _animated_sprite = $AnimatedSprite2D
@onready var light : PointLight2D = $PointLight2D

func _ready():
	SignalBus.npc_saved.connect(_on_npc_saved)
	SignalBus.npc_lost.connect(_on_npc_lost)

func _on_npc_saved():
	light.energy += 0.5
	light.texture_scale += 0.10
	
func _on_npc_lost():
	light.energy -= 0.5
	light.texture_scale -= 0.10

func _process(_delta: float) -> void:
	var direction: = get_direction()
	velocity = speed * direction
	if velocity != Vector2.ZERO:
		if velocity.x != 0:
			_animated_sprite.flip_h = false if velocity.x > 0 else true
		_animated_sprite.play("walk")
		move_and_slide()
	else:
		_animated_sprite.play("idle")
		
		
#disable diagonal movement
func get_direction() -> Vector2:
	var direction: = Vector2.ZERO
	if Input.is_action_pressed("move_right") || Input.is_action_pressed("move_left"):
		direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
		
	elif Input.is_action_pressed("move_down") || Input.is_action_pressed("move_up"):
		direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return direction


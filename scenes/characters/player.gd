extends CharacterBody2D

@export var speed: int = 80
@export var trap_duration : float = 10.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var light : PointLight2D = $PointLight2D

enum Status {
	HEALTHY,
	BLIND,
	CONFUSED
}

var status : Status
var light_stats : Dictionary = {
	energy = 1,
	light_range = 0.15
}

func _ready():
	status = Status.HEALTHY
	SignalBus.npc_saved.connect(_on_npc_saved)
	SignalBus.npc_lost.connect(_on_npc_lost)
	SignalBus.trap_activated.connect(_on_activated_trap.bind())

func _on_activated_trap(_trap_type):
	match _trap_type:
		TrapType.Type.BLINDNESS:
			set_blindness()
		TrapType.Type.CONFUSION:
			set_confusion()
		_:
			print("Invalid trap type")
		
func _on_npc_saved():
		light_stats["energy"] += 0.5
		light_stats["light_range"] += 0.10
		if status != Status.BLIND:
			light.energy = light_stats["energy"]
			light.texture_scale = light_stats["light_range"]
	
func _on_npc_lost():
	light_stats["energy"] -= 0.5
	light_stats["light_range"] -= 0.10
	if status != Status.BLIND:
		light.energy = light_stats["energy"]
		light.texture_scale = light_stats["light_range"]

func _process(_delta: float) -> void:
	var direction: = get_direction()
	velocity = speed * direction
	if status == Status.CONFUSED:
		velocity = -velocity
	if velocity != Vector2.ZERO:
		if velocity.x != 0:
			_animated_sprite.flip_h = false if velocity.x > 0 else true
		_animated_sprite.play("walk")
		move_and_slide()
	else:
		_animated_sprite.play("idle")
		
	if status == Status.HEALTHY:
		light.energy = light_stats["energy"]
		light.texture_scale = light_stats["light_range"]
		
#disable diagonal movement
func get_direction() -> Vector2:
	var direction: = Vector2.ZERO
	if Input.is_action_pressed("move_right") || Input.is_action_pressed("move_left"):
		direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
		
	elif Input.is_action_pressed("move_down") || Input.is_action_pressed("move_up"):
		direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return direction

func set_blindness():
	status = Status.BLIND
	light.energy /= 4
	light.texture_scale /= 4
	await get_tree().create_timer(trap_duration).timeout
	light.energy *= 4
	light.texture_scale *= 4
	set_healthy()
	
func set_confusion():
	status = Status.CONFUSED
	await get_tree().create_timer(trap_duration).timeout
	set_healthy()
	
func set_healthy():
	status = Status.HEALTHY

extends CharacterBody2D

@export var movement_target: Marker2D
#@export var navigation_agent: NavigationAgent2D
@export var movement_speed: float = 100

@onready var navigation_agent = $NavigationAgent2D


func _ready():
	call_deferred("set_entity_target")
	
func set_entity_target():
	await get_tree().physics_frame
	navigation_agent.target_position = movement_target.position

func _physics_process(delta):		
	if navigation_agent.is_navigation_finished():
		return
	
	var current_entity_position = global_position
	var next_path_position = navigation_agent.get_next_path_position()
	
	var new_velocity = next_path_position - current_entity_position
	new_velocity = new_velocity.normalized()
	
	new_velocity *= movement_speed

	velocity = new_velocity
	move_and_slide()

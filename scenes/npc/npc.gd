extends CharacterBody2D

@export var run_speed : int = 20
@onready var detection_zone : CollisionShape2D = %DetectionZone/CollisionShape2D
@onready var animation : AnimatedSprite2D = %AnimatedSprite2D
@onready var light : PointLight2D = $PointLight2D

var player = null
var detection_zone_radius : float = 0.0
var saved : bool = false

func _ready():
	velocity = Vector2.ZERO
	detection_zone_radius = detection_zone.get_shape().radius

func _physics_process(_delta):
	if player and is_within_radius(player.position):
		#TODO: Use a NavigationAgent2D to follow the player using astar algorithm.
		# Although, I like the 'dumbness' of the npcs
		velocity = position.direction_to(player.position) * run_speed
		animation.play("walk")
		if !saved:
			SignalBus.npc_saved.emit()
			saved = true
	else:
		velocity = Vector2.ZERO
		animation.play("idle")
		if saved:
			SignalBus.npc_lost.emit()
			saved = false
		player = null
	move_and_slide()

func _on_detection_zone_body_entered(body):
	player = body
	
func is_within_radius(player_position: Vector2) -> bool:
	if (player_position.distance_to(self.position) <= (3.0 * detection_zone_radius)):
		return true
	return false

extends CharacterBody2D

@export var run_speed : int = 20
@onready var detection_zone : CollisionShape2D = %DetectionZone/CollisionShape2D
@onready var light : PointLight2D = $PointLight2D

var player = null
var detection_zone_radius : float = 0.0
var saved : bool = false

func _ready():
	velocity = Vector2.ZERO
	detection_zone_radius = detection_zone.get_shape().radius

func _physics_process(_delta):
	if player and is_within_radius(player.position):
		velocity = position.direction_to(player.position) * run_speed
		if !saved:
			SignalBus.npc_saved.emit()
			light.texture_scale = 0.05
			saved = true
	else:
		velocity = Vector2.ZERO
		if saved:
			SignalBus.npc_lost.emit()
			light.texture_scale = 0.25
			saved = false
		player = null
	move_and_slide()

func _on_detection_zone_body_entered(body):
	player = body
	
func is_within_radius(player_position: Vector2) -> bool:
	if (player_position.distance_to(self.position) <= (3.0 * detection_zone_radius)):
		return true
	return false

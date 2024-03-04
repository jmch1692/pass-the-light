extends Node2D
class_name Trap

@onready var animation_player : AnimationPlayer = %Animator
@onready var sprite_2d : Sprite2D = %Sprite2D

var trap_type : TrapType.Type

func _on_area_2d_body_entered(_body):
	if !animation_player.is_playing():
		# Reset alpha
		sprite_2d.self_modulate.a = 255
		animation_player.play("active")

func _on_animation_player_animation_finished(_anim_name):
	SignalBus.trap_activated.emit(trap_type)
	queue_free()

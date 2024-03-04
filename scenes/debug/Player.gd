extends CharacterBody2D

var movement_speed = 200

func handle_input():
	var move_direction = Input.get_vector("left", "right", "up", "down")
	velocity = move_direction * movement_speed

func _physics_process(delta):
	handle_input()
	move_and_slide()

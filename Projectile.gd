# we extend Node2D because we need to inherit position
extends Node2D

@export var speed: int = 250

var velocity: Vector2 = Vector2.ZERO

func update_velocity():
	velocity.x = speed
	velocity = velocity.rotated(rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta

# remove projectile when it leaves screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

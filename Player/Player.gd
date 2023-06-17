extends CharacterBody2D

@export_category("Movement")
@export var ACCELERATION: int  = 512
@export var MAX_VELOCITY: int = 64
@export var FRICTION = 256
@export var GRAVITY: int = 200
@export var JUMP_FORCE: int = 128
@export var MAX_FALL_VELOCITY: int = 128

@onready var sprite = $Sprite
@onready var sprite_animator = $SpriteAnimator

# the function that we use every time we manipulate CharacterBody
# delta needs to be applied to values that change over time
func _physics_process(delta):
	apply_gravity(delta)
	var input_axis = Input.get_axis("ui_left", "ui_right")
	if is_moving(input_axis):
		apply_acceleration(input_axis, delta)
	else:
		apply_friction(delta)
	jump_check()
	update_animations(input_axis)
	move_and_slide()

# part of writing self-documenting code: moved code from _physics_process into
# a separate function, instead of commenting code inside _physics_process
func is_moving(input_axis):
	return input_axis != 0

# Godot applies delta to velocity (change in position over time), which is why we don't
# Gravity and acceleration represent change in velocity over time, so we do need to apply delta
func apply_acceleration(input_axis, delta):	
	velocity.x  = move_toward(velocity.x, input_axis * MAX_VELOCITY, ACCELERATION * delta)

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func jump_check():
	# is_on_floor() relies on motion mode to be Grounded to work
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = -JUMP_FORCE
	else:
		# code to control our jump better: we can do a full jump or a smaller jump
		if Input.is_action_just_released("ui_up") and velocity.y < -JUMP_FORCE/2:
			velocity.y = - JUMP_FORCE/2

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, MAX_FALL_VELOCITY, GRAVITY * delta)

func update_animations(input_axis):
	if is_moving(input_axis):
		sprite_animator.play("Run")
		# flipping the cahracter based on the movement direction
		sprite.scale.x = sign(input_axis)
	else:
		sprite_animator.play("Idle")

	if not is_on_floor():
		sprite_animator.play("Jump")


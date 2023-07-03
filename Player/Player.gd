extends CharacterBody2D

const DustEffectScene = preload("res://Effects/DustEffect.tscn")

@export_category("Movement")
@export var ACCELERATION: int  = 512
@export var MAX_VELOCITY: int = 64
@export var FRICTION = 256
@export var GRAVITY: int = 200
@export var JUMP_FORCE: int = 128
@export var MAX_FALL_VELOCITY: int = 128

@onready var sprite = $Sprite
@onready var sprite_animator = $SpriteAnimator
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var player_blaster = $PlayerBlaster

# the function that we use every time we manipulate CharacterBody
# delta needs to be applied to values that change over time
func _physics_process(delta):
	apply_gravity(delta)
	var input_axis = Input.get_axis("move_left", "move_right")
	if is_moving(input_axis):
		apply_acceleration(input_axis, delta)
	else:
		apply_friction(delta)
	jump_check()
	if Input.is_action_just_pressed("fire"):
		player_blaster.fire_bullet()
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()

func create_dust_effect():
	Utils._instantiate_scene_on_world(DustEffectScene, global_position)

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
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = -JUMP_FORCE
	if not is_on_floor():
		# code to control our jump better: we can do a full jump or a smaller jump
		if Input.is_action_just_released("jump") and velocity.y < -JUMP_FORCE/2:
			velocity.y = - JUMP_FORCE/2

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, MAX_FALL_VELOCITY, GRAVITY * delta)

func update_animations(input_axis):
	# flipping the cahracter based on the movement direction
	# we want this to happen even when character is not moving
	sprite.scale.x = sign(get_local_mouse_position().x)
	# check so that our character doesn't disappear when mouse is on origin point
	if abs(sprite.scale.x) != 1: sprite.scale.x = 1
	
	if is_moving(input_axis):
		sprite_animator.play("Run")
		# reverse animation when we're facing opposite direction
		sprite_animator.speed_scale = input_axis * sprite.scale.x
		
	else:
		sprite_animator.play("Idle")

	if not is_on_floor():
		sprite_animator.play("Jump")


class_name Player
extends CharacterBody2D

@export var max_move_speed := 100
@export var movement_mode := MovementMode.FIXED
@export var accelleration := 400
@export var friction := 150

enum MovementMode {FIXED, DRIFTY, ICY}

@onready var animationTree := $AnimationTree as AnimationTree
@onready var animationState := animationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback


func _ready() -> void:
	self.velocity = Vector2.ZERO
	# affect move_and_slide(), this mode is for top-down 2d games
	self.set_motion_mode(MotionMode.MOTION_MODE_FLOATING)
	
	if not animationState:
		print_debug("Failed to get animation node state machine playback")


func _physics_process(delta: float) -> void:
	# get move direction from user's directional inputs
	var input_direction := Vector2.ZERO
	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_direction = input_direction.normalized()
	
	# update animation of player
	self._update_animation(input_direction)
	
	# update velocity bases on movement modes
	self._calculate_velocity(delta, input_direction)
	
	# move player
	move_and_slide()


func _update_animation(input_direction: Vector2) -> void:
	if input_direction != Vector2.ZERO:
		animationTree.set("parameters/Idling/blend_position", input_direction)
		animationTree.set("parameters/Running/blend_position", input_direction)
		animationState.travel("Running")
	else:
		animationState.travel("Idling")
	return


func _calculate_velocity(delta: float, input_direction: Vector2) -> void:
	match movement_mode:
		MovementMode.FIXED:
			# fixed speed
			self.velocity = input_direction * max_move_speed
		MovementMode.DRIFTY:
			# simple acceleration
			self.velocity = self.velocity.move_toward(input_direction * max_move_speed, accelleration * delta)
		MovementMode.ICY:
			# low friction, for icy ground
			self.velocity += input_direction * accelleration * delta * 0.75
			if input_direction == Vector2.ZERO:
				self.velocity = self.velocity.move_toward(Vector2.ZERO, friction * delta)
			self.velocity = self.velocity.limit_length(max_move_speed)
	return

class_name Player
extends CharacterBody2D

@export var max_move_speed := 100
@export var movement_mode := MovementMode.FIXED
@export var accelleration := 400
@export var friction := 150

enum MovementMode {
	FIXED, # change speed instantly
	DRIFTY, # simplified acceleration
	ICY # low friction
}

enum ActionState {
	MOVING,
	ROLLING,
	ATTACKING
}

@onready var anim_tree := $AnimationTree as AnimationTree
@onready var anim_state := anim_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

var action_state := ActionState.MOVING


func _ready() -> void:
	self.velocity = Vector2.ZERO
	# affect move_and_slide(), this mode is for top-down 2d games
	self.set_motion_mode(MotionMode.MOTION_MODE_FLOATING)
	
	anim_tree.active = true
	if not anim_state:
		print_debug("Failed to get animation node state machine playback")


func _physics_process(delta: float) -> void:
	# handle base on player's action state
	match action_state:
		ActionState.MOVING:
			self._moving_state(delta)
			# transition
			if Input.is_action_just_pressed("attack"):
				action_state = ActionState.ATTACKING
			if Input.is_action_just_pressed("roll"):
				action_state = ActionState.ROLLING
				
		ActionState.ATTACKING:
			self._attacking_state(delta)
			if Input.is_action_just_pressed("roll"):
				action_state = ActionState.ROLLING
				
		ActionState.ROLLING:
			self._rolling_state()
			action_state = ActionState.MOVING
	return


func _moving_state(delta: float) -> void:
	# get move direction from user's directional inputs
	var input_direction := Vector2.ZERO
	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_direction = input_direction.normalized()
	
	# update animation of player
	self._update_move_animation(input_direction)
	
	# update internal velocity bases on movement modes
	self._calculate_velocity(delta, input_direction)
	
	# move player
	move_and_slide()
	return


func _update_move_animation(input_direction: Vector2) -> void:
	# set position of blend 2d in Animation Tree
	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idling/blend_position", input_direction)
		anim_tree.set("parameters/Running/blend_position", input_direction)
		anim_tree.set("parameters/Attack/blend_position", input_direction)
		anim_state.travel("Running")
	else:
		anim_state.travel("Idling")
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


func _attacking_state(delta: float) -> void:
	# play animation
	anim_state.travel("Attack")
	# smoothly stop the player and reset velocity
	self.velocity = self.velocity.move_toward(Vector2.ZERO, accelleration * delta)
	move_and_slide()


func _rolling_state(_delta: float = 0.4) -> void:
	pass


func _on_trigger_action_finished() -> void:
	action_state = ActionState.MOVING

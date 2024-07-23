class_name Player
extends CharacterBody2D

@export var max_move_speed := 100
@export var movement_mode := MovementMode.FIXED
@export var rolling_speed := 150
@export var rolling_cooldown := 1.5
@export var accelleration := 400
@export var friction := 150

enum MovementMode {
	FIXED, # change speed instantly
	DRIFTY, # simplified acceleration
	ICY # low friction
}

enum ActionState {
	IDLING,
	MOVING,
	ROLLING,
	ATTACKING
}

@onready var anim_tree := $AnimationTree as AnimationTree
@onready var anim_player := $AnimationPlayerSub as AnimationPlayer
@onready var anim_state := anim_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

var action_state := ActionState.IDLING
var input_direction := Vector2.ZERO
var facing_direction := Vector2.DOWN
var dt_rolling := rolling_cooldown
var is_movement_locked := false


func _ready():
	self.velocity = Vector2.ZERO
	
	# affect move_and_slide(), this mode is for top-down 2d games
	self.set_motion_mode(MotionMode.MOTION_MODE_FLOATING)
	
	anim_tree.active = true
	if not anim_state:
		print_debug("Failed to get animation node state machine playback")
		
	PlayerState.connect("zero_health", Callable(self, "_on_damageable_zero_health"))


func _physics_process(delta: float):
	# update cooldown
	# TODO: save last used timestamp instead
	dt_rolling += delta
	
	_update_input_direction()
	
	if not is_movement_locked:
		var to_attack = Input.is_action_just_pressed("attack")
		var to_roll = Input.is_action_just_pressed("roll") and dt_rolling >= rolling_cooldown
		
		if to_attack: return self._trigger_attack()
		if to_roll: return self._trigger_roll()

	# handle base on player's action state
	match action_state:
		ActionState.MOVING, ActionState.IDLING:
			self._process_moving(delta)
		ActionState.ATTACKING:
			self._process_attacking(delta)
		ActionState.ROLLING:
			self._process_rolling()

func _update_input_direction():
	# get move direction from user's directional inputs
	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_direction = input_direction.normalized()

func _process_moving(delta: float):
	# update animation of player
	self._update_move_animation()
	
	# update internal velocity bases on movement modes
	self._calculate_and_set_velocity(delta)
	
	# move player
	move_and_slide()

func _update_move_animation():
	# set position of blend 2d in Animation Tree
	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idling/blend_position", input_direction)
		anim_tree.set("parameters/Running/blend_position", input_direction)
		facing_direction = input_direction
		anim_state.travel("Running")
	else:
		anim_state.travel("Idling")

func _calculate_and_set_velocity(delta: float):
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

func _trigger_attack():
	# play animation
	anim_state.travel("Attack")
	anim_tree.set("parameters/Attack/blend_position", facing_direction)

	is_movement_locked = true
	action_state = ActionState.ATTACKING

func _process_attacking(delta: float):
	# smoothly stop the player and reset velocity
	self.velocity = self.velocity.move_toward(Vector2.ZERO, accelleration * delta * 0.7)
	move_and_slide()

func _trigger_roll():
	# play animation
	anim_state.travel("Roll")
	anim_tree.set("parameters/Roll/blend_position", facing_direction)
	
	dt_rolling = 0.0
	is_movement_locked = true
	action_state = ActionState.ROLLING

func _process_rolling():
	# maintaining velocity base on pre-roll input direction
	self.velocity = facing_direction * rolling_speed
	move_and_slide()

func _on_trigger_action_finished():
	is_movement_locked = false
	action_state = ActionState.IDLING
	_update_move_animation()

func _on_hurtbox_area_entered(area: Area2D):
	# lose health
	var hitbox := area as Hitbox
	if hitbox: 
		PlayerState.health -= hitbox.damage
	else:
		PlayerState.health -= 1
	anim_player.play("Blinking")

func _on_damageable_zero_health():
	self.call_deferred("queue_free")

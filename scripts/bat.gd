extends CharacterBody2D

@export var max_move_speed := 80
@export var acceleration := 100
@export var knock_back_speed := 125
@export	var air_friction := 75
@export var ai_state := AiState.IDLING

enum AiState {
	IDLING,
	WANDERING,
	CHASING
}

@onready var damageable := $Damageable as Damageable
@onready var target_detector := $TargetDetectionZone as TargetDetector
@onready var anim_sprite := $AnimatedSprite2D as AnimatedSprite2D

@onready var die_vfx := preload("res://scenes/shared/bat_death_vfx.tscn") as PackedScene
@onready var vfx_instance := die_vfx.instantiate() as AnimatedSprite2D


func _physics_process(delta: float) -> void:
	self._look_for_target()
	
	match ai_state:
		AiState.IDLING:
			self.velocity = self.velocity.move_toward(Vector2.ZERO, air_friction * delta)
		AiState.WANDERING:
			pass
		AiState.CHASING:
			var direction: Vector2 = (target_detector.curr_target.global_position - self.global_position).normalized()
			self.velocity = self.velocity.move_toward(direction * max_move_speed, acceleration * delta)
			anim_sprite.flip_h = self.velocity.x < 0
	
	move_and_slide()


func _look_for_target() -> void:
	if not target_detector:
		ai_state = AiState.IDLING
		return
	if target_detector.curr_target:
		ai_state = AiState.CHASING
	else:
		ai_state = AiState.IDLING


func _on_hurtbox_area_entered(area: Area2D):
	# being knocked back
	var parent := area.get_parent() as Node2D
	var direction = (self.global_position - parent.global_position).normalized()
	self.velocity = direction * knock_back_speed
	
	# lose health
	var hitbox := area as Hitbox
	if damageable and hitbox: 
		damageable.current_health -= hitbox.damage
	elif damageable:
		damageable.current_health -= 1


func _on_damageable_zero_health():
	var world = get_tree().current_scene
	world.add_child(vfx_instance)
	vfx_instance.global_position = self.global_position
	self.call_deferred("queue_free")

extends CharacterBody2D

@export var knock_back_speed := 125
@export	var air_friction := 100

@onready var damageable := $Damageable as Damageable
@onready var die_vfx := preload("res://scenes/shared/bat_death_vfx.tscn") as PackedScene
@onready var vfx_instance := die_vfx.instantiate() as AnimatedSprite2D


func _physics_process(delta: float) -> void:
	self.velocity = self.velocity.move_toward(Vector2.ZERO, air_friction * delta)
	move_and_slide()


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

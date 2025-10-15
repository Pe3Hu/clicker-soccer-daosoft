class_name Ball
extends CharacterBody2D


var speed: float  = 30
var direction: Vector2 = Vector2.UP
var punch_speed_scale = 1.5


func _ready() -> void:
	pass


func _physics_process(delta_: float) -> void:
	velocity = direction * speed
	var collision = move_and_collide(delta_ * velocity)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		direction = velocity.normalized()
		speed *= punch_speed_scale

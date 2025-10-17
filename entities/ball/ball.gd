##An object that the user needs to react to in order to win the game.
##
## Key Features:
## - Bouncing effect when appearing.
## - Player kick target.
## - The possibility of being sent into Fans when kicked
## - Replenishing the game victory counter.
class_name Ball
extends CharacterBody2D


#limit beyond which the speed cannot accelerate
const max_speed: float = 200

#parent node
@export var world: World

#parameters affecting velocity
var direction: Vector2 = Vector2.LEFT
var speed: float  = 25
var punch_speed_scale: float = 1.5

#bounce height in initial tween
var bounce_height: int = 6

#flag that shifts the collision layer of the ball when a player kicks
var is_kicked: bool = false:
	set(value_):
		is_kicked = value_
		speed = max_speed
		
		if is_kicked:
			set_collision_layer_value(2, false)
			set_collision_mask_value(2, false)

#kick targets
var fans: Array[Fan]

#animation player
@onready var animations: AnimationPlayer = $AnimationPlayer
#timer that sets the frequency of bounces
@onready var bounce_timer: Timer = $BounceTimer
#player body sprite
@onready var sprite: Sprite2D = $Sprite2D


#inital bounce animation
func _ready() -> void:
	bounce_animation()
	
#change direction to the next Fan
func follow_fans() -> void:
	if !fans.is_empty():
		#selecting the next Fan to target
		var next_fan = fans.pop_front()
		
		if next_fan != null:
			#changing Fan state to alarm
			next_fan.set_alarm()
			#change in direction depending on self and Fan the positions
			direction = (next_fan.global_position - global_position).normalized()
	
func _physics_process(delta_: float) -> void:
	#ball rotation
	sprite.rotation += -PI * 2  * delta_
	
	#basic movement and collision with other nodes
	velocity = direction * speed
	var collision = move_and_collide(delta_ * velocity)
	
	if collision:
		var collider = collision.get_collider()
		
		#Fan collision check
		if collider is Fan:
			#changing Fan state to unconscious
			collider.set_unconscious()
		
		#Ball collision check
		if collider is Ball:
			#acceleration of speed
			speed = min(speed * punch_speed_scale, max_speed)
		
		#change in velocity and direction after a collision
		velocity = velocity.bounce(collision.get_normal())
		direction = velocity.normalized()
	
func _on_bounce_timer_timeout() -> void:
	bounce_animation()
	
#fading bounce animation
func bounce_animation() -> void:
	if bounce_height > 1:
		#smooth upward shift
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(sprite, "position", Vector2(0, -bounce_height), 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($CollisionShape2D, "position", Vector2(0, -bounce_height), 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		await tween.finished
		
		#if the Ball is still on the screen
		if get_tree() != null:
			#smooth downward shift
			tween = get_tree().create_tween().set_parallel(true)
			tween.tween_property(sprite, "position", Vector2(0, bounce_height), 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			tween.tween_property($CollisionShape2D, "position", Vector2(0, bounce_height), 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			
			#reducing jump impulse
			bounce_height *= 0.75
	
#remove the scene when it goes off screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	world.balls.remove_child(self)
	queue_free()

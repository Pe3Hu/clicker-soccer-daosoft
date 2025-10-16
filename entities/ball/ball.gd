class_name Ball
extends CharacterBody2D


const max_speed: float = 200

@export var world: World

var direction: Vector2 = Vector2.LEFT

var speed: float  = 25
var punch_speed_scale: float = 1.5

var bounce_height: int = 6
var is_kicked: bool = false:
	set(value_):
		is_kicked = value_
		
		if is_kicked:
			set_collision_layer_value(2, false)
			set_collision_mask_value(2, false)

var fans: Array[Fan]

@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var bounce_timer: Timer = $BounceTimer
@onready var sprite: Sprite2D = $Sprite2D
@onready var kick_path: KickPath = $KickPath
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	_on_bounce_timer_timeout()
	
func _physics_process(delta_: float) -> void:
	sprite.rotation += -PI * 2  * delta_
	
	#if is_kicked:
		#velocity = Vector2.ZERO
		#kick_path.path_follow.progress += speed * delta_
		#position = kick_path.path_follow.global_position
		#return
		
	
	if is_kicked:
		update_velocity() 
	velocity = direction * speed
	var collision = move_and_collide(delta_ * velocity)
	
	if collision:
		var collider = collision.get_collider()
		if collider is Fan:
			collider.set_unconscious()
		
		velocity = velocity.bounce(collision.get_normal())
		direction = velocity.normalized()
		speed = min(speed * punch_speed_scale, max_speed)
	
	update_animation()
	
func update_velocity() -> void:
	if nav_agent.get_current_navigation_path().is_empty(): return
	
	var current_agent_position = global_position
	var next_path_position = nav_agent.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * speed
	
	#Status change at the end of movement
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	
	#Applying velocity
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity_: Vector2) -> void:
	velocity = safe_velocity_
	
func update_animation() -> void:
	#animations.play("bounce")
	pass
	
func follow_fans() -> void:
	if !fans.is_empty():
		var next_fan = fans.pop_front()
		next_fan.set_alarm()
		direction = (next_fan.global_position - global_position).normalized()
		#nav_agent.target_position = next_fan.position
	
func _on_bounce_timer_timeout() -> void:
	if bounce_height > 1:
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "position", Vector2(0, -bounce_height), 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($CollisionShape2D, "position", Vector2(0, -bounce_height), 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		await tween.finished
		
		if get_tree() != null:
			tween = get_tree().create_tween()
			tween.set_parallel(true)
			tween.tween_property(sprite, "position", Vector2(0, bounce_height), 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			tween.tween_property($CollisionShape2D, "position", Vector2(0, bounce_height), 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			bounce_height *= 0.75
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	world.balls.remove_child(self)
	queue_free()

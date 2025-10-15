class_name Player
extends CharacterBody2D


const speed: float = 120

@export var world: World

@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var is_start: bool = true


func _ready() -> void:
	nav_agent.target_position = Vector2(72, 172)
	
func _physics_process(_delta: float) -> void:
	update_animation()
	update_velocity() 
	move_and_collide(_delta * velocity)
	
func update_velocity() -> void:
	var current_agent_position = global_position
	var next_path_position = nav_agent.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * speed
	
	#Status change at the end of movement
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	#Applying velocity
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity_: Vector2) -> void:
	velocity = safe_velocity_
	
func update_animation() -> void:
	
	if velocity.length() == 0:
		#Disabling animation in case of inactivity
		if animations.is_playing():
			animations.stop()
	else:
		#Determining the direction of movement
		var angle = velocity.angle()
		
		if angle < 0:
			angle += PI * 2
		
		var direction = "Right"
		
		if angle >= PI/4 and angle < PI*3/4: direction = "Down"
		elif angle >= PI*3/4 and angle < PI*5/4: direction = "Right"#"Left"
		elif angle >= PI*5/4 and angle < PI*7/4: direction = "Up"
		animations.play("walk" + direction)


func _on_navigation_agent_2d_navigation_finished() -> void:
	if is_start:
		is_start = false
		world.start_generate_balls()

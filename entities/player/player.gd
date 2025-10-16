class_name Player
extends CharacterBody2D


const speed: float = 100

@export var world: World
@export var camera: Camera2D

@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var trajectory: KickTrajectory = $KickTrajectory

enum State{START_RUNNING, RUNNING, END_RUNNIG, RESTING}
var current_state: State:
	set(value_):
		current_state = value_

var stadium_expand_distance: int = 15 * 16
var passed_distance: float = 0:
	set(value_):
		passed_distance = value_
		
		if passed_distance >= stadium_expand_distance:
			passed_distance -= stadium_expand_distance
			world.stadium.extend_tilemaps()

var follow_ball: Ball:
	set(value_):
		follow_ball = value_
		
		if follow_ball != null:
			nav_agent.target_position = follow_ball.position
var kick_ball: Ball

var kick_direction: Vector2

func _ready() -> void:
	start_run()
	
func start_run() -> void:
	current_state = State.START_RUNNING
	nav_agent.target_position = position + Vector2(0, 160)
	
func _physics_process(delta_: float) -> void:
	update_animation()
	if current_state == State.RESTING: return
	
	update_velocity() 
	move_and_collide(delta_ * velocity)
	
	if kick_ball != null:
		trajectory.update_vertexs(kick_direction, 100, 19.8, delta_)
		#var kick_angle = randf_range(-PI/3, -PI / 2)
		#var kick_direction = Vector2.from_angle(kick_angle) #kick_ball.position - position
		#trajectory.update_vertexs(kick_direction, 100, 19.8, delta_)
	
	
	passed_distance += delta_ * velocity.x
	camera.position.x += delta_ * velocity.x
	
func update_velocity() -> void:
	match current_state:
		State.RUNNING:
			if follow_ball != null:
				if follow_ball.position.x < position.x:
					follow_ball = null
					var direction = Vector2.RIGHT
					velocity = direction * speed
					return
				else:
					nav_agent.target_position = follow_ball.position
			else:
				var direction = Vector2.RIGHT
				velocity = direction * speed
				return
	
	var current_agent_position = global_position
	var next_path_position = nav_agent.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * speed
	
	#Status change at the end of movement
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		
		if follow_ball != null:
			follow_ball = null
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
	
func kick() -> void:
	if current_state == State.RUNNING:
		if kick_ball != null:
			#world.add_kick_path(kick_ball, trajectory.points)
			kick_ball.kick_path.curve.clear_points()
			
			for point in trajectory.points:
				kick_ball.kick_path.curve.add_point(point)
			
			kick_ball.position = kick_ball.kick_path.path_follow.global_position
			kick_ball.is_kicked = true
			kick_ball = null
			trajectory.visible = false
			world.kick_counter += 1
	
func go_rest() -> void:
	world.ball_timer.stop()
	current_state = State.END_RUNNIG
	var cloakrooms = world.stadium.cloakrooms.get_children()
	cloakrooms.sort_custom(func (a, b): return a.position.distance_to(position) < b.position.distance_to(position))
	var cloakroom = cloakrooms.front()
	nav_agent.target_position = cloakroom.position
	
func _on_navigation_agent_2d_navigation_finished() -> void:
	match current_state:
		State.START_RUNNING:
			world.ball_timer.start()
			current_state = State.RUNNING
		State.END_RUNNIG:
			current_state = State.RESTING
			world.rest_timer.start()
	
func _on_vision_area_body_entered(body_: Node2D) -> void:
	if current_state == State.RUNNING:
		if body_ is Ball:
			if follow_ball == null:
				follow_ball = body_
			else:
				var distance_old = position.distance_to(follow_ball.position)
				var distance_new = position.distance_to(body_.position)
				
				if distance_new < distance_old:
					follow_ball = body_
	
func _on_kick_area_body_entered(body_: Node2D) -> void:
	if current_state == State.RUNNING:
		if body_ is Ball:
			if kick_ball == null:
				kick_ball = body_
				trajectory.visible = true
				var kick_angle = randf_range(-PI/6, -PI / 3)
				kick_direction = Vector2.from_angle(kick_angle) #kick_ball.position - position
	
func _on_kick_area_body_exited(body_: Node2D) -> void:
	if body_ is Ball:
		if kick_ball == body_:
			kick()
			kick_ball = null
	
func _input(event_: InputEvent) -> void:
	if event_.is_action("kick"):
		kick()

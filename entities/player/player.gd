##An object that represents the user's ability to interact with the game.
##
## Key Features:
## - Entering Grass field at the start of the race.
## - Tracking incoming Balls.
## - Kicking Ball into the tribune.
## - Return to the tribune at the end of the race.
## - Motion animation
class_name Player
extends CharacterBody2D


#player movement speed
const speed: float = 100
#angle of movement towards the tribune
const KICK_ANGLE_DEVIATION: float = -PI / 6

#parent node
@export var world: World
#player-tethered camera
@export var camera: Camera2D

#state options
enum State{START_RUNNING, RUNNING, END_RUNNIG, RESTING}
#state machine
var current_state: State:
	set(value_):
		current_state = value_

#milestone responsible for drawing the stadium tilemaps
var stadium_expand_distance: int = 15 * world.TILE_SIZE.x
#trip meter
var passed_distance: float = 0:
	set(value_):
		passed_distance = value_
		
		if passed_distance >= stadium_expand_distance:
			passed_distance -= stadium_expand_distance
			world.stadium.extend_tilemaps()

#Player follows this Ball
var follow_ball: Ball:
	set(value_):
		follow_ball = value_
		
		if follow_ball != null:
			nav_agent.target_position = follow_ball.position
#Player can kick this Ball
var kick_ball: Ball
#direction to kick kick_ball
var kick_direction: Vector2

#animation player
@onready var animations: AnimationPlayer = $AnimationPlayer
#navigation agent
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
#trajectory of a hypothetical kick
@onready var trajectory: KickTrajectory = $KickTrajectory


func _ready() -> void:
	start_run()
	
#update parameters when leaving the tribune
func start_run() -> void:
	current_state = State.START_RUNNING
	nav_agent.target_position = position + Vector2(0, 160)
	
func _physics_process(delta_: float) -> void:
	update_animation()
	#end of processing in case of Player rest
	if current_state == State.RESTING: return
	
	update_velocity() 
	move_and_collide(delta_ * velocity)
	
	#ball trajectory update
	if kick_ball != null:
		trajectory.update_vertexs(kick_direction, 100, 20, delta_)
	
	#updated path traveled
	passed_distance += delta_ * velocity.x
	#UI shift
	camera.position.x += delta_ * velocity.x
	
#velocity recalculation 
func update_velocity() -> void:
	match current_state:
		State.RUNNING:
			if follow_ball != null:
				#stop chasing follow_ball if it rolls behind the Player's back
				if follow_ball.position.x < position.x:
					follow_ball = null
					move_to_right()
					return
				else:
					#chasing follow_ball
					nav_agent.target_position = follow_ball.position
			else:
				#move right by default
				move_to_right()
				return
	
	#standard actions when using navigation agent
	var current_agent_position = global_position
	var next_path_position = nav_agent.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * speed
	
	#status change at the end of movement
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		
		if follow_ball != null:
			follow_ball = null
		
		return
	
	#applying velocity
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity_: Vector2) -> void:
	velocity = safe_velocity_
	
#sprite animation depending on the direction of movement
func update_animation() -> void:
	if velocity.length() == 0:
		#disabling animation in case of inactivity
		animations.play("idle")
	else:
		#determining the direction of movement
		var angle = velocity.angle()
		
		if angle < 0:
			angle += PI * 2
		
		var direction = "Right"
		
		if angle >= PI/4 and angle < PI*3/4: direction = "Down"
		#since there is no movement to the left in assets, movement to the right is used
		elif angle >= PI*3/4 and angle < PI*5/4: direction = "Right"#"Left"
		elif angle >= PI*5/4 and angle < PI*7/4: direction = "Up"
		animations.play("walk" + direction)
	
#change velocity to the right
func move_to_right() -> void:
	var direction = Vector2.RIGHT
	velocity = direction * speed
	
#applying kick
func kick() -> void:
	if current_state == State.RUNNING:
		if kick_ball != null:
			kick_ball.is_kicked = true
			
			#filling kick_ball fan target array
			kick_ball.fans.append_array(trajectory.fans)
			kick_ball.follow_fans()
			
			#reset kick_ball
			kick_ball = null
			trajectory.visible = false
			
			#replenishment of the counter of successfully kicked balls
			world.kick_counter += 1
	
#preparations at the end of the race
func go_rest() -> void:
	world.ball_timer.stop()
	current_state = State.END_RUNNIG
	find_nearest_cloakroom()
	
#set nearest cloakroom as navigation agent's target
func find_nearest_cloakroom() -> void:
	var cloakrooms = world.stadium.cloakrooms.get_children()
	cloakrooms.sort_custom(func (a, b): return a.position.distance_to(position) < b.position.distance_to(position))
	var cloakroom = cloakrooms.front()
	nav_agent.target_position = cloakroom.position
	
#starting timers at the start and end of race
func _on_navigation_agent_2d_navigation_finished() -> void:
	match current_state:
		State.START_RUNNING:
			world.ball_timer.start()
			current_state = State.RUNNING
		State.END_RUNNIG:
			current_state = State.RESTING
			world.rest_timer.start()
	
#interaction with Balls in sight
func _on_vision_area_body_entered(body_: Node2D) -> void:
	if current_state == State.RUNNING:
		if body_ is Ball:
			#set ball as dafault 
			if follow_ball == null:
				follow_ball = body_
			#override when finding a closer ball
			else:
				var distance_old = position.distance_to(follow_ball.position)
				var distance_new = position.distance_to(body_.position)
				
				if distance_new < distance_old:
					follow_ball = body_
	
#interaction with Balls in the strike zone
func _on_kick_area_body_entered(body_: Node2D) -> void:
	if current_state == State.RUNNING:
		if body_ is Ball:
			#set ball as dafault 
			if kick_ball == null:
				kick_ball = body_
				trajectory.visible = true
				#set random direction for the Ball's kick trajectory
				var kick_angle = randf_range(KICK_ANGLE_DEVIATION, KICK_ANGLE_DEVIATION * 2)
				kick_direction = Vector2.from_angle(kick_angle)
	
#reset kick_ball when it leaves the strike zone
func _on_kick_area_body_exited(body_: Node2D) -> void:
	if body_ is Ball:
		if kick_ball == body_:
			kick_ball = null
			trajectory.visible = false
	
#allowing the user to kick
func _input(event_: InputEvent) -> void:
	if event_.is_action("kick"):
		kick()

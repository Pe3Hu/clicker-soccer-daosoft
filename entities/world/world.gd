##An object 
##
## Key Features:
## - 
## - 
class_name World 
extends Node


#stadium tile size
const TILE_SIZE: Vector2 = Vector2(16, 16)
const GRASS_TILE_HEIGHT: int = 7

#parameters for creating a batch of Balls
const MAX_BALL_COUNTER: int = 3
const MAX_BALL_ANGLE_DEVIATION: float = PI / 3
const MAX_BALL_SPEED_SCALE: float = 2.5
const MIN_BALL_HEIGHT_SCALE: float = 0.2
const BALL_SPAWN_OFFSET: Vector2 = Vector2(20, 7) * TILE_SIZE 

@export var ball_scene: PackedScene
@export var kick_path_scene: PackedScene

#stadium nodes
@onready var stadium: Node2D = $Stadium
@onready var time_label: Label = %TimeLabel
#player nodes
@onready var player: Player = $Player
@onready var rest_timer: Timer = $RestTimer
@onready var kicks: Node2D = $Kicks
#ball nodes
@onready var balls: Node2D = $Balls
@onready var ball_timer: Timer = $BallTimer
@onready var ball_label: Label = %BallLabel

#game start time
var time_start: float

#number of ball kicks required to complete the race
var max_kicks: int = 25
#current number of successful kicks
var kick_counter: int: 
	set(value_):
		kick_counter = value_
		
		#check at the end of the race
		if kick_counter >= max_kicks:
			kick_counter -= max_kicks
			player.go_rest()
		
		#displaying the current number of successful kicks
		%BallLabel.text = "Balls: " + str(kick_counter) + "/" + str(max_kicks)


#set starting values
func _ready() -> void:
	kick_counter = 0
	time_start = Time.get_unix_time_from_system()
	
func _on_ball_timer_timeout() -> void:
	set_rnd_ball_timer()
	spawn_balls()
	
#random deviation in the time of creating a batch of Balls
func set_rnd_ball_timer() -> void:
	ball_timer.wait_time = randf_range(0.7, 0.9)
	
#create a batch of a random number of balls
func spawn_balls() -> void:
	var ball_count = randi_range(1, MAX_BALL_COUNTER)
	
	for _i in ball_count:
		#position the ball behind the screen relative to the player's position
		var y = float(_i + randf_range(0.0, 0.5)) / ball_count * TILE_SIZE.y * GRASS_TILE_HEIGHT + BALL_SPAWN_OFFSET.y
		var x = BALL_SPAWN_OFFSET.x + player.position.x
		add_ball(Vector2(x, y))
	
#creating a ball with random starting parameters
func add_ball(position_: Vector2) -> void:
	var ball = ball_scene.instantiate()
	ball.position = position_
	var direction_angle = randf_range(-MAX_BALL_ANGLE_DEVIATION, MAX_BALL_ANGLE_DEVIATION)
	ball.direction = ball.direction.rotated(direction_angle)
	var speed_scale = randf_range(1.0, MAX_BALL_SPEED_SCALE)
	ball.speed *= speed_scale
	var height_scale = randf_range(MIN_BALL_HEIGHT_SCALE, 1.0)
	ball.bounce_height *= height_scale
	ball.world = self
	balls.add_child(ball)
	
#exit the application by pressing escape button
func _input(event_) -> void:
	if event_ is InputEventKey:
		match event_.keycode:
			KEY_ESCAPE:
				get_tree().quit()
	
func _process(_delta: float) -> void:
	update_time_label()
	
#dividing elapsed time into minutes and seconds
func update_time_label() -> void:
	var seconds = int(Time.get_unix_time_from_system() - time_start) 
	var minutes = floor(seconds / 60)
	seconds = seconds % 60
	var second_str = str(seconds) + " sec"
	var minute_str = ""
	
	if minutes > 0:
		minute_str = str(minutes) + " min "
	
	time_label.text = "Time: " + minute_str + second_str
	
#starting player movement
func _on_rest_timer_timeout() -> void:
	player.start_run()

class_name World 
extends Node


const TILE_SIZE: Vector2 = Vector2(16, 16)
const BALL_SPAWN_OFFSET: Vector2 = Vector2(20, 7) * TILE_SIZE 

@onready var player: Player = $Player
@onready var stadium: Node2D = $Stadium
@onready var balls: Node2D = $Balls
@onready var kicks: Node2D = $Kicks
@onready var ball_timer: Timer = $BallTimer
@onready var rest_timer: Timer = $RestTimer
@onready var ball_label: Label = %BallLabel
@onready var time_label: Label = %TimeLabel
@onready var labels: MarginContainer = %Labels

@export var ball_scene: PackedScene
@export var kick_path_scene: PackedScene

var time_start: float

var max_kicks: int = 50
var kick_counter: int: 
	set(value_):
		kick_counter = value_
		
		if kick_counter >= max_kicks:
			kick_counter -= max_kicks
			player.go_rest()
		
		%BallLabel.text = "Balls: " + str(kick_counter)


func _ready() -> void:
	time_start = Time.get_unix_time_from_system()
	
func _on_ball_timer_timeout() -> void:
	set_rnd_ball_timer()
	spawn_balls()
	
func set_rnd_ball_timer() -> void:
	ball_timer.wait_time = randf_range(0.7, 0.9)
	
func spawn_balls() -> void:
	var ball_count = randi_range(1, 3)
	
	for _i in ball_count:
		var y = float(_i + randf_range(0.0, 0.5)) / ball_count * TILE_SIZE.y * 7 + BALL_SPAWN_OFFSET.y
		var x = BALL_SPAWN_OFFSET.x + player.position.x
		add_ball(Vector2(x, y))
	
func add_ball(position_: Vector2) -> void:
	var ball = ball_scene.instantiate()
	ball.position = position_
	var direction_angle = randf_range(-PI/3, PI/3)
	ball.direction = ball.direction.rotated(direction_angle)
	var speed_scale = randf_range(1, 2.5)
	ball.speed *= speed_scale
	var height_scale = randf_range(0.2, 1.0)
	ball.bounce_height *= height_scale
	ball.world = self
	balls.add_child(ball)

#func add_kick_path(ball_: Ball, points_: Array) -> void:
	#var kick_path = kick_path_scene.instantiate()
	#
	#for point in points_:
		#kick_path.curve.add_point(point)
	#
	#kicks.add_child(kick_path)
	#kick_path.ball = ball_
	
func _input(event_) -> void:
	if event_ is InputEventKey:
		match event_.keycode:
			KEY_ESCAPE:
				get_tree().quit()
	
func _process(_delta: float) -> void:
	var seconds = int(Time.get_unix_time_from_system() - time_start) 
	var minutes = floor(seconds / 60)
	seconds = seconds % 60
	var second_str = str(seconds) + " sec"
	var minute_str = ""
	
	if minutes > 0:
		minute_str = str(minutes) + " min "
	
	time_label.text = "Time: " + minute_str + second_str
	
func _on_rest_timer_timeout() -> void:
	player.start_run()

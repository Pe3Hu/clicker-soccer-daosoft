class_name KickPath
extends Path2D


@export var ball: Ball:
	set(value_):
		ball = value_
		#ball.world.balls.remove_child(ball)
		#%PathFollow2D.add_child(ball)
		#ball.is_kicked = true

@onready var path_follow: PathFollow2D = %PathFollow2D


#func _process(delta: float) -> void:
	#if %PathFollow2D.progress_ratio < 1.0:
		#%PathFollow2D.progress_ratio += 0.5 * delta
	#else:
		#pass

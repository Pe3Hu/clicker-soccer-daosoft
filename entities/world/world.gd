class_name World 
extends Node


@onready var player: Player = $Player
@onready var stadium: Node2D = $Stadium
@onready var balls: Node2D = $Balls

@export var ball_scene: PackedScene


func start_generate_balls() -> void:
	pass
	
	
func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
	

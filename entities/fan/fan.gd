class_name Fan
extends CharacterBody2D


var stadium: Stadium
var id: int:
	set(value_):
		id = value_
		idle_sprite.texture = load("res://entities/fan/images/idle/" + str(id) + ".png")
		unconscious_sprite.texture = load("res://entities/fan/images/unconscious/" + str(id) + ".png")
		alarm_sprite.texture = load("res://entities/fan/images/alarm/" + str(id) + ".png")

@onready var idle_sprite: Sprite2D = $IdleSprite
@onready var unconscious_sprite: Sprite2D = $UnconsciousSprite
@onready var alarm_sprite: Sprite2D = $AlarmSprite
@onready var animations: AnimationPlayer = $AnimationPlayer


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	stadium.fans.remove_child(self)
	queue_free()
	
func _process(_delta: float) -> void:
	if id != null:
		animations.play("idle")
	
func set_unconscious() -> void:
	animations.stop()
	idle_sprite.visible = false
	unconscious_sprite.visible = true
	alarm_sprite.visible = false
	
func set_alarm() -> void:
	animations.stop()
	idle_sprite.visible = false
	unconscious_sprite.visible = false
	alarm_sprite.visible = true

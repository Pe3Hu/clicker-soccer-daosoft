##An object to fill the background as well as a possible target for fun.
##
## Key Features:
## - Mass animation of a crowd of inaction.
## - Fear of being hit by a Ball.
## - Loss of consciousness when colliding with Ball.
class_name Fan
extends CharacterBody2D


#parent node
var stadium: Stadium
#random value ​​determining which fan image is used

var id: int:
	set(value_):
		id = value_
		idle_sprite.texture = load("res://entities/fan/images/idle/" + str(id) + ".png")
		unconscious_sprite.texture = load("res://entities/fan/images/unconscious/" + str(id) + ".png")
		alarm_sprite.texture = load("res://entities/fan/images/alarm/" + str(id) + ".png")

#state options
enum State{IDLE, ALARM, UNCONSCIOUS}
#state machine
var current_state: State:
	set(value_):
		#impossibility of changing the state during unconscious state
		if current_state == State.UNCONSCIOUS: return
		
		current_state = value_
		
		match current_state:
			State.ALARM:
				set_alarm()
			State.UNCONSCIOUS:
				set_unconscious()

#sprites
@onready var idle_sprite: Sprite2D = $IdleSprite
@onready var unconscious_sprite: Sprite2D = $UnconsciousSprite
@onready var alarm_sprite: Sprite2D = $AlarmSprite
#animation player
@onready var animations: AnimationPlayer = $AnimationPlayer


#change the visibility for alarm state
func set_alarm() -> void:
	animations.stop()
	idle_sprite.visible = false
	unconscious_sprite.visible = false
	alarm_sprite.visible = true
	
#change the visibility for unconscious state
func set_unconscious() -> void:
	animations.stop()
	idle_sprite.visible = false
	unconscious_sprite.visible = true
	alarm_sprite.visible = false
	
#play animation when idle state
func _process(_delta: float) -> void:
	if id != null:
		if current_state == State.IDLE:
			animations.play("idle")
	
#remove the scene when it goes off screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	stadium.fans.remove_child(self)
	queue_free()

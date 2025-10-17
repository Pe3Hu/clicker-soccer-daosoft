##An object to which the Player will run if the race ends.
##
## Key Features:
## - Anchor for rest between raceser.
class_name Cloakroom
extends Area2D


var stadium: Stadium


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	stadium.cloakrooms.remove_child(self)
	queue_free()

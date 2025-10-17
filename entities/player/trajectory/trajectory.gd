##An object 
##
## Key Features:
## - 
## - 
class_name KickTrajectory
extends Line2D


#kick targets
var fans: Array[Fan]


#recalculation of trajectory points
func update_vertexs(direction_: Vector2, speed_: float, gravity_: float, delta_: float) -> void:
	#number of points affecting the drawing length
	var max_points: int = 400
	#reset parameters
	clear_points()
	fans.clear()
	var current_position: Vector2 = Vector2.ZERO
	var velocity = direction_ * speed_
	
	for _i in max_points:
		add_point(current_position)
		#application of gravity effect
		velocity.y += gravity_ * delta_
		
		#collision tracking in test mode
		var collision = %TestBody.move_and_collide(velocity * delta_, false, true, true)
		if collision:
			var collider = collision.get_collider()
			#keep Fan on the way
			if collider is Fan:
				fans.append(collider)
			
			#change in velocity after a collision
			velocity = velocity.bounce(collision.get_normal()) * 0.6
		
		#progress along the calculated path
		current_position += velocity * delta_
		%TestBody.position = current_position

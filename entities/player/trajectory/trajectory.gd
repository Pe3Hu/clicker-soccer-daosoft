class_name KickTrajectory
extends Line2D



func update_vertexs(direction_: Vector2, speed_: float, gravity_: float, delta_: float) -> void:
	var max_points: int = 400
	clear_points()
	var current_position: Vector2 = Vector2.ZERO
	var velocity = direction_ * speed_
	
	for _i in max_points:
		add_point(current_position)
		velocity.y += gravity_ * delta_
		
		var collision = %TestBody.move_and_collide(velocity * delta_, false, true, true)
		if collision:
			velocity = velocity.bounce(collision.get_normal()) * 0.6
		
		current_position += velocity * delta_
		%TestBody.position = current_position

extends CharacterBody3D

var shape_cast
var speed = 3
var follow_player = false
var player = null
var direction
var target_velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shape_cast = $radiusShape


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var collision_count = shape_cast.get_collision_count()
	if collision_count > 0:
		for i in range(collision_count):
			var collider = shape_cast.get_collider(i)
			
			if collider.is_in_group("player"):
				follow_player = true
				player = collider
	else:
		follow_player = false
		
	if follow_player:
		move_to_chase_player(player)
	else:
		velocity = Vector3.ZERO
		
	move_and_slide()
	
# movement of enemy to follow direction of player object
func move_to_chase_player(player: Object) -> void:
	if player != null:
		var player_pos = player.global_position
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_position, player_pos)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		if result && result.collider is CharacterBody3D:
			self.look_at(player_pos)
			direction = global_position.direction_to(player_pos)
			
			target_velocity.x = direction.x * speed
			target_velocity.z = direction.z * speed
			velocity = target_velocity
		else:
			velocity = Vector3.ZERO
	else:
		velocity = Vector3.ZERO
		
		

extends CharacterBody3D

@export var speed = 4

var target_velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	var vertical_direction = Input.get_axis("move_up", "move_down")
	
	if horizontal_direction:
		velocity.x = speed * horizontal_direction
	
	#basic input movement
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		direction.z -= 1
	if Input.is_action_pressed("move_down"):
		direction.z += 1

	#direction movement
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$pivot.basis = Basis.looking_at(direction)

	#ground velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	#Collision checking based on top of enemy
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider() == null:
			continue
			
	velocity = target_velocity
	move_and_slide()
	
	if direction != Vector3.ZERO:
		$AnimationPlayer.speed_scale = 4
	else: 
		$AnimationPlayer.speed_scale = 1

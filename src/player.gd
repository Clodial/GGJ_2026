extends CharacterBody3D

@export var speed = 4
@export var backSpeed = 2
@export var turnSpeed = 0.025 
@export var basic_mask: PackedScene
@export var basic_mask_label = "basic"
var is_displaying_basic_mask = false
@export var web_mask: PackedScene
@export var web_mask_label = "web"
var is_displaying_web_mask = false
@export var is_tank_controls = true

var backCamera
var mainCamera

var target_velocity = Vector3.ZERO
var masks = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	backCamera = $pivot/backCamera
	mainCamera = $pivot/mainCamera
	mainCamera.make_current()
	backCamera.current = false
	pass
	
func return_mask_list():
	return masks

func remove_mask(mask_name: String) -> void:
	masks.erase(mask_name)

func _process(delta: float) -> void:
	process_mask()

func _physics_process(delta: float) -> void:
	
	var direction = Vector3.ZERO
	
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	var vertical_direction = Input.get_axis("move_up", "move_down")
	
	if Input.is_action_pressed("move_down"):
		if backCamera.current != true:
			mainCamera.clear_current()
			backCamera.make_current()
	elif Input.is_action_pressed("move_up"):
		if mainCamera.current != true:
			backCamera.clear_current()
			mainCamera.make_current()
	
	#basic tank input movement
	if is_tank_controls:
		if Input.is_action_pressed("move_forward") and Input.is_action_pressed("move_back"):
			velocity.x = 0
			velocity.z = 0

		elif Input.is_action_pressed("move_up"):
			var forwardVector = -Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
			velocity = -forwardVector * speed
			
		elif Input.is_action_pressed("move_down"):
			var backwardVector = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
			velocity = -backwardVector * backSpeed
		
		#If pressing nothing stop velocity
		else:
			velocity.x = 0
			velocity.z = 0
		
		# IF turn left WHILE moving back, turn right
		if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_back"):
			rotation.z -= direction.y + turnSpeed
			rotation.z = clamp(rotation.x, -50, 90)
			rotation.y -= direction.y + turnSpeed
		
		elif Input.is_action_pressed("move_left"):
			rotation.z += direction.y - turnSpeed
			rotation.z = clamp(rotation.x, -50, 90)
			rotation.y += direction.y + turnSpeed

		# IF turn right WHILE moving back, turn left
		if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_back"):
			rotation.z += direction.y - turnSpeed
			rotation.z = clamp(rotation.x, -50, 90)
			rotation.y += direction.y + turnSpeed
			
		elif Input.is_action_pressed("move_right"):
			rotation.z -= direction.y + turnSpeed
			rotation.z = clamp(rotation.x, -50, 90)
			rotation.y -= direction.y + turnSpeed
		
	else:
		if horizontal_direction:
			velocity.x = speed * horizontal_direction
		
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
		
		velocity = target_velocity

	#Collision checking based on top of enemy
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider() == null:
			continue
			
	move_and_slide()
	
	if direction != Vector3.ZERO:
		$AnimationPlayer.speed_scale = 4
	else: 
		$AnimationPlayer.speed_scale = 1
		
	
func process_mask():
	if masks.size() <= 0:
		if !$pivot/mask_marker_1.get_children().is_empty():
			is_displaying_basic_mask = false
			for n in $pivot/mask_marker_1.get_children():
				$pivot/mask_marker_1.remove_child(n)
				n.queue_free()
				
	else:
		if masks.has(basic_mask_label):
			if !is_displaying_basic_mask:
				is_displaying_basic_mask = true
				var basic_mask_display = basic_mask.instantiate()
				$pivot/mask_marker_1.add_child(basic_mask_display)
		elif !$pivot/mask_marker_1.get_children().is_empty():
			is_displaying_basic_mask = false
			for n in $pivot/mask_marker_1.get_children():
				$pivot/mask_marker_1.remove_child(n)
				n.queue_free()
			
	if is_displaying_basic_mask:
		speed = 12
	else:
		speed = 4

func _on_player_collision_body_entered(body: Node3D) -> void:
	#mask check
	if body.is_in_group("mask"):
		masks.append(body.return_mask_type())
		body.queue_free()
		$mask_get_sfx.play()
	pass # Replace with function body.

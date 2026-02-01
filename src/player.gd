extends CharacterBody3D

@export var speed = 4
@export var basic_mask: PackedScene
@export var basic_mask_label = "basic"
var is_displaying_basic_mask = false
@export var web_mask: PackedScene
@export var web_mask_label = "web"
var is_displaying_web_mask = false

var target_velocity = Vector3.ZERO
var masks = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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
		
	
func process_mask():
	if masks.size() <= 0:
		if !$pivot/mask_marker_1.get_children().is_empty():
			is_displaying_basic_mask = false
			for n in $pivot/mask_marker_1.get_children():
				$pivot/mask_marker_1.remove_child(n)
				n.queue_free()
				
	else:
		if masks.has(basic_mask_label) and !is_displaying_basic_mask:
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

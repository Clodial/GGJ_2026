extends StaticBody3D

var player_cast
var instructions
var mask_placement
var player_in_range = false
var has_mask = false
@export var need_mask = "basic"
@export var mask_model: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mask_placement = $MaskMarker
	player_cast = $playerRadius
	instructions = $maskInstruction
	instructions.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var collision_count = player_cast.get_collision_count()
	var incoming_collider = null
	if collision_count > 0:
		for i in range(collision_count):
			var collider = player_cast.get_collider(i)
			
			if collider.is_in_group("player"):
				player_in_range = true
				incoming_collider = collider
	else:
		player_in_range = false
		
	if player_in_range:
		if !has_mask and incoming_collider.return_mask_list().has(need_mask):
			instructions.visible = true
			if Input.is_action_just_pressed("action") and incoming_collider != null:
				incoming_collider.remove_mask(need_mask)
				has_mask = true
				spawn_mask()
		else:
			instructions.visible = false
	else:
		instructions.visible = false
		incoming_collider = null
		
func spawn_mask():
	var mask_container = mask_model.instantiate()
	add_child(mask_container)
	mask_container.position = mask_placement.position

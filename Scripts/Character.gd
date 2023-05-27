extends CharacterBody3D


const SPEED = 5.0
const CROUCH_SPEED = 2.0
const JUMP_VELOCITY = 4.5
@export var sensitivity = 3.0
var crouched := false
var flashlight_is_out := false
var light_level : float
@onready var footsteps : AudioStreamPlayer = $Footsteps
var surface_type :String = "TBD"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready(): 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var surface_result:Dictionary = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, global_position + Vector3.DOWN, 1, [self]))
	var new_surface_type = "Concrete"
	if surface_result.size() > 0: 
		if surface_result.has("collider"): 
			var surface_object:Node3D = surface_result["collider"]
			if surface_object.has_meta("surface_type"):
				new_surface_type = surface_object.get_meta("surface_type")
	
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed("mouse_left") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	light_level = get_node("LightDetect").light_level

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed = SPEED
	if Input.is_action_pressed("crouch"): 
		if !crouched:
			$AnimationPlayer.play("crouch")
			crouched = true
	else: 
		if crouched: 
			var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position, position + Vector3(0,2,0), 1, [self]))
			if result.size() == 0: 
				$AnimationPlayer.play("uncrouch")
				crouched = false
	if crouched: 
		speed = CROUCH_SPEED
	
	if Input.is_action_just_pressed("flashlight"): 
		if flashlight_is_out: 
			$AnimationPlayer.play("flashlight_hide")
		else: 
			$AnimationPlayer.play("flashlight_show")
		flashlight_is_out = !flashlight_is_out
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if new_surface_type != surface_type: 
			surface_type = new_surface_type
			footsteps.stream = AudioManager.sound_map[surface_type].walk_stream_wav
			print(surface_type)
		if not footsteps.playing:
			footsteps.play()
	else:
		if footsteps.playing: 
			footsteps.stop()
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event): 
	if event is InputEventMouseMotion: 
		rotation.y -= event.relative.x / 1000 * sensitivity
		$Camera3D.rotation.x -= event.relative.y / 1000 * sensitivity
		rotation.x = clamp(rotation.x, PI/-2, PI/2)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -2, 2)

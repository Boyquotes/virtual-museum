extends CharacterBody3D

signal input
signal interact

@onready var animation_player = $Model/YBot/AnimationPlayer
@onready var model = $Model
@onready var raycast = $Model/RayCast3D

@export var SPEED = 2.3
@export var RUNNING_FACTOR = 2.0
@export var JUMP_VELOCITY = 4.5
@export var ROTATE_FACTOR = 10.0

var is_walking: bool = false
var is_running: bool = false
var current_look_direction: Vector3 = Vector3(0, 0, 0)
var look_factor: float = 0.1
 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta: float) -> void:
	if(raycast.is_colliding()):
		var collider = raycast.get_collider()
		emit_signal("interact", collider)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	var input_dir = Vector2(Input.get_action_raw_strength("move_x"), Input.get_action_raw_strength("move_y"))
	emit_signal("input", input_dir)
	
	if(!input_dir.is_finite()):
		input_dir = Vector2(0,0)
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		
		# Check if we are running
		is_running = Input.is_action_pressed("running")
		
		if is_running:
			velocity.x = direction.x * SPEED * RUNNING_FACTOR
			velocity.z = direction.z * SPEED * RUNNING_FACTOR
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			
		#model.look_at(direction + position)
		model.rotation.y = lerp_angle(model.rotation.y, atan2(-velocity.x, -velocity.z), delta * ROTATE_FACTOR)
		
		if !is_walking:
			is_walking = true
			
		if is_running:
			animation_player.play("Running")
		elif is_walking:
			animation_player.play("Walking")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if is_walking or is_running:
			is_walking = false
			is_running = false
			animation_player.play("Idle")

	move_and_slide()

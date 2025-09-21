extends CharacterBody3D

# --- Tunables ---
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 9.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0025

# Gravity from project settings (Godot 4)
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var cam: Camera3D = $Camera3D

# We'll keep yaw (left/right) on the body, and pitch (up/down) on the camera
var yaw := 0.0
var pitch := 0.0
const MAX_PITCH := deg_to_rad(89.0)

func _ready() -> void:
	# Capture the mouse for FPS-style look
	#pass
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Godot 4 way to capture/hide cursor. :contentReference[oaicite:0]{index=0}

func _process(delta: float) -> void:
# TODO: add escape key functionality for pausing the game
	pass

func _unhandled_input(event: InputEvent) -> void:
	# Mouse look
	if event is InputEventMouseMotion:
		# When the mouse is captured, use event.relative for movement. :contentReference[oaicite:1]{index=1}
		yaw   -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -MAX_PITCH, MAX_PITCH)

		rotation.y = yaw           # rotate the body around Y (yaw)
		cam.rotation.x = pitch     # rotate the camera around X (pitch)

	# Press Esc to release the mouse; click to recapture
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Basic gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Sprint toggle
	var speed = sprint_speed if Input.is_action_pressed("player_sprint") else walk_speed

	# Read WASD as a 2D vector using your custom actions.
	# get_vector(neg_x, pos_x, neg_y, pos_y) → Vector2. :contentReference[oaicite:2]{index=2}
	var input2d := Input.get_vector(
		"player_walk_left", "player_walk_right",
		"player_walk_forward", "player_walk_backward"
	)

	# Convert 2D input into world-space 3D (x, z) relative to where the player is facing
	var direction: Vector3 = (transform.basis * Vector3(input2d.x, 0.0, input2d.y)).normalized()

	# Apply horizontal velocity
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# Smoothly decelerate when no input
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	# Jump
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = jump_velocity

	# Move the character and slide along surfaces (Godot 4 CharacterBody3D). :contentReference[oaicite:3]{index=3}
	move_and_slide()

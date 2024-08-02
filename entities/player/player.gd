extends CharacterBody3D


const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const sensitivity := 0.3

var camera_distance := 3.0
var camera_elevation := 3.5
var prev_mouse_position := Vector2()
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	prev_mouse_position = get_viewport().get_mouse_position()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var mouse_delta = event.relative
		rotate_y(deg_to_rad(-mouse_delta.x * sensitivity))

func _physics_process(delta):
	if not is_on_floor(): velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

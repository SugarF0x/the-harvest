extends CharacterBody3D


const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const SENSITIVITY := 0.3
const CAMERA_PAN_CLAMP := 10.0
const CAMERA_MAX_ZOOM = 2.0
const CAMERA_MIN_ZOOM = 5.0

var prev_mouse_position := Vector2()
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_3d = $Camera3D
@onready var body = $Body
@onready var initial_pan = rad_to_deg(camera_3d.rotation.x)
@onready var min_camera_position = body.position.direction_to(camera_3d.position) * CAMERA_MIN_ZOOM
@onready var max_camera_position = body.position.direction_to(camera_3d.position) * CAMERA_MAX_ZOOM

func _input(event):
	handle_mouse_controls(event)
	handle_camera_rotation(event)
	handle_mouse_follow(event)
	handle_camera_zoom(event)

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


func handle_mouse_controls(event: InputEvent):
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_RIGHT: return
	
	if event.pressed: 
		prev_mouse_position = get_viewport().get_mouse_position()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_viewport().warp_mouse(prev_mouse_position)

func handle_camera_rotation(event: InputEvent):
	if not event is InputEventMouseMotion: return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): return
	
	var mouse_delta = event.relative
	rotate_y(deg_to_rad(-mouse_delta.x * SENSITIVITY))
	
	var new_pan = clampf(rad_to_deg(camera_3d.rotation.x) - mouse_delta.y * SENSITIVITY, initial_pan - CAMERA_PAN_CLAMP, initial_pan + CAMERA_PAN_CLAMP)
	camera_3d.rotation.x = deg_to_rad(new_pan)

func handle_camera_zoom(event: InputEvent):
	var direction = 0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP): direction = 1
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN): direction = -1
	if !direction: return
	
	camera_3d.position = (camera_3d.position + camera_3d.position.direction_to(body.position) * direction).clamp(max_camera_position, min_camera_position)

func handle_mouse_follow(event: InputEvent):
	if not event is InputEventMouseMotion: return
	var mouse_position = event.position

	var from = camera_3d.project_ray_origin(mouse_position)
	var to = camera_3d.project_ray_normal(mouse_position) * 1000
	
	var parameters = PhysicsRayQueryParameters3D.new()
	parameters.from = from
	parameters.to = to
	parameters.collision_mask = 1
	var result = get_world_3d().direct_space_state.intersect_ray(parameters)
#
	if result: 
		var pos = result.position
		pos[1] = position[1]
		body.look_at(pos)

extends RigidBody3D

var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0

var linearx
var linearz

@export var friction := 1

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var spring_arm := $TwistPivot/PitchPivot/SpringArm3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input := Vector3.ZERO
	input.x = Input.get_axis("left", "right")
	input.z = Input.get_axis("forward", "back")
	
	apply_central_force(twist_pivot.basis * input * 50000 * delta)
	
	print("initial velocity: ", linear_velocity)
	
	linear_velocity.x = dampen(linear_velocity.x, friction * delta)
	linear_velocity.z = dampen(linear_velocity.z, friction * delta)
	
	print("final velocity: ", linear_velocity)
	
	if Input.is_action_just_pressed("exit"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,
		deg_to_rad(-50),
		deg_to_rad(50)
	)
	twist_input = 0.0
	pitch_input = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sens
			pitch_input = - event.relative.y * mouse_sens
			
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		if spring_arm.spring_length < 10:
			spring_arm.spring_length += 0.4
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		if spring_arm.spring_length > 0.4:
			spring_arm.spring_length -= 0.4
		
func dampen(u: float, damp_constant: float) -> float:
	if u < 0.0:
		return min(u + damp_constant, 0.0)
	elif u > 0.0:
		return max(u - damp_constant, 0.0)
	else:
		return u
	

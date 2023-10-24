extends CharacterBody3D

# node variables
@onready var camera_mount := $CameraMount
@onready var camera := $CameraMount/ThirdPersonCamera
var current_car: Object

# physics constants
const SPEED := 1.0
const JUMP_VELOCITY := 3.0
var GRAVITY: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# button input variables
var jump_pressed := false

# mouse input variables
var mouse_sensitivity := 0.003
var twist_input := 0.0
var pitch_input := 0.0

# logic variables
var is_inside_car := false


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    camera.current = true


func _process(_delta) -> void:
    rotate_y(twist_input)
    camera_mount.rotate_x(pitch_input)
    camera_mount.rotation.x = clamp(camera_mount.rotation.x, -0.75, 0.75)

    # reset the camera rotation
    twist_input = 0.0
    pitch_input = 0.0


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("reset"):
        get_tree().reload_current_scene()
    elif event.is_action_pressed("emergency_kill"):
        get_tree().quit()

    if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        if not is_inside_car:
            if event is InputEventMouseMotion:
                twist_input = -event.relative.x * mouse_sensitivity
                pitch_input = -event.relative.y * mouse_sensitivity

        if event.is_action_pressed("ui_cancel"):
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    if event.is_action_pressed("use"):
        if is_inside_car:
            leave_car()


func _physics_process(delta: float) -> void:
    if is_inside_car:
        return

    # apply gravity
    if not is_on_floor():
        velocity.y -= GRAVITY * delta

    # handle jumping
    jump_pressed = Input.is_action_pressed("jump")
    if jump_pressed and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # get the input direction and handle the player movement or deceleration
    var input_dir := Input.get_vector("left", "right", "forward", "backward")
    var input_vector := Vector3(input_dir.x, 0, input_dir.y)
    var direction := (basis * input_vector).normalized()

    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()


func leave_car() -> void:
    # player settings
    is_inside_car = false
    camera.current = true

    # car settings
    current_car.is_player_inside = false

    # move the player
    position = Vector3(0, 1, 0)
    #self.reparent(get_tree().current_scene)

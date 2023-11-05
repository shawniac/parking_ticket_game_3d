extends CharacterBody3D

# nodes
@export var _camera: Camera3D
@onready var _player_pcam: PhantomCamera3D = %PlayerPhantomCamera3D
@onready var _model: Node3D = %Model
@onready var picture_frame: Sprite3D = %PictureFrame

# exports
@export var mouse_sensitivity: float = 0.05

@export var min_yaw: float = -89.9
@export var max_yaw: float = 50

@export var min_pitch: float = 0
@export var max_pitch: float = 360

# gameplay
var current_car: Object
var is_inside_car := false

# physics constants
const SPEED := 1.0
const JUMP_VELOCITY := 3.0
var GRAVITY: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
    if _player_pcam.get_follow_mode() == _player_pcam.Constants.FollowMode.THIRD_PERSON:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("reset"):
        get_tree().reload_current_scene()
    elif event.is_action_pressed("emergency_quit"):
        get_tree().quit()
    elif event.is_action_pressed("take_picture"):
        take_picture()

    if _player_pcam.get_follow_mode() == _player_pcam.Constants.FollowMode.THIRD_PERSON:
        _set_pcam_rotation(_player_pcam, event)

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
    if Input.is_action_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # get the input direction and handle the player movement or deceleration
    var input_dir := Input.get_vector("left", "right", "forward", "backward")
    var input_vector := Vector3(input_dir.x, 0, input_dir.y)
    var direction := (basis * input_vector).normalized()

    # get the camera direction
    # TODO make use of this
    var cam_dir: Vector3 = -_camera.global_transform.basis.z

    if direction:
        direction = direction.rotated(Vector3.UP, _camera.rotation.y).normalized()

        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()

    # rotate the player model accordingly
    if velocity.length() > 0.2:
        var look_direction := Vector2(-velocity.z, -velocity.x)
        _model.rotation.y = look_direction.angle()


func _set_pcam_rotation(pcam: PhantomCamera3D, event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var pcam_rotation_degrees: Vector3

        # Assigns the current 3D rotation of the SpringArm3D node - so it starts off where it is in the editor
        pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()

        # Change the X rotation
        pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity

        # Clamp the rotation in the X axis so it go over or under the target
        pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_yaw, max_yaw)

        # Change the Y rotation value
        pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity

        # Sets the rotation to fully loop around its target, but witout going below or exceeding 0 and 360 degrees respectively
        pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_pitch, max_pitch)

        # Change the SpringArm3D node's rotation and rotate around its target
        pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)


func take_picture() -> void:
    print("snapping pic")

    await RenderingServer.frame_post_draw
    var picture = get_viewport().get_texture().get_image()

    #picture.save_webp("res://picture.webp")

    print("picture taken")

    var picture_texture = ImageTexture.new()
    picture_texture = ImageTexture.create_from_image(picture)
    picture_texture.set_size_override(Vector2(128, 128))

    picture_frame.texture = picture_texture

    print("picture saved")


func leave_car() -> void:
    # player settings
    is_inside_car = false
    # TODO set pcam priorities here instead
    #camera.current = true

    # car settings
    current_car.is_player_inside = false

    # move the player
    position = Vector3(0, 1, 0)
    #self.reparent(get_tree().current_scene)

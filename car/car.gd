extends VehicleBody3D

const STEER_DAMPENING := 0.6

@onready var camera := $Camera3D

var is_player_inside := false

@export var max_rpm := 250
@export var max_torque := 200


func use(player: CharacterBody3D) -> void:
    # player settings
    player.is_inside_car = true
    player.current_car = self

    # car settings
    is_player_inside = true
    camera.current = true

    # move the player
    player.position = Vector3(0, -1, 0)
    #player.reparent(self)


func _physics_process(delta: float) -> void:
    if is_player_inside:
        # get user input and steer
        var acceleration = Input.get_axis("backward", "forward")
        steering = lerp(steering, Input.get_axis("right", "left") * STEER_DAMPENING, 5 * delta)

        # handbrake
        if Input.is_action_pressed("handbrake"):
            brake = 1
        else:
            brake = 0

        # apply torque
        var rpm: float = abs($WheelRearLeft.get_rpm())
        engine_force = acceleration * max_torque * ( 1 - rpm/max_rpm ) * 0.5
    else:
        engine_force = 0.0

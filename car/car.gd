extends VehicleBody3D

@onready var camera := $Camera3D

var is_player_inside := false

var max_rpm := 250
var max_torque := 200


func use(player: CharacterBody3D) -> void:
    # player settings
    player.is_inside_car = true
    player.current_car = self

    # car settings
    is_player_inside = true
    camera.current = true

    # move the player
    player.position = Vector3(0, -10, 0)
    #player.reparent(self)


func _physics_process(delta: float) -> void:
    if is_player_inside:
        # get user input
        steering = lerp(steering, Input.get_axis("right", "left") * 0.4, 5 * delta)
        var acceleration = Input.get_axis("backward", "forward")

        # apply torque
        var rpm: float = abs($WheelRearLeft.get_rpm())
        engine_force = acceleration * max_torque * ( 1 - rpm/max_rpm )
    else:
        engine_force = 0.0

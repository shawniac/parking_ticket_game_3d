extends RayCast3D

@onready var prompt: Label = $Prompt

func _ready() -> void:
    add_exception(owner)


func _physics_process(_delta: float) -> void:
    prompt.text = ""

    if is_colliding():
        var detected_object = get_collider()

        if detected_object.has_method("use"):
            prompt.text = detected_object.name

            if Input.is_action_just_pressed("use"):
                detected_object.use(owner)

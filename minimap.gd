extends TextureRect

var minimap_texture: Texture
var player: Node


func _ready():
    player = get_node("/root/Player")


func _draw():
    # Draw the minimap texture.
    draw_texture(minimap_texture, Vector2.ZERO)

    # Draw the player's position on the minimap.
    var player_position = player.get_global_position()
    draw_circle(player_position, 5, Color.RED)

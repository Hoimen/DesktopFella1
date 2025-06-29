extends Panel

@onready var held_sprite: Sprite2D = get_node_or_null("Held")

func _ready():
	if held_sprite:
		held_sprite.visible = false
	else:
		push_warning("Held node not found. Check the node path.")

	mouse_filter = Control.MOUSE_FILTER_STOP  # Ensures Panel receives click input

extends Node

@export var popup_scene: PackedScene
@export var trigger_button: Button

var active_window: Window = null

func _ready():
	if trigger_button:
		trigger_button.pressed.connect(_on_button_pressed)
	else:
		push_warning("No button assigned in the inspector!")

func _on_button_pressed():
	if not popup_scene:
		push_warning("No popup scene assigned in the inspector!")
		return

	# Prevent multiple windows
	if is_instance_valid(active_window):
		active_window.popup_centered()  # Optionally bring it to front
		return

	var window_instance = popup_scene.instantiate()

	if window_instance is Window:
		get_tree().root.add_child(window_instance)
		window_instance.show()
		active_window = window_instance

		# Clear reference when window is closed
		window_instance.tree_exited.connect(_on_window_closed)
	else:
		push_error("Popup scene must have a Window node as its root to preserve window settings!")

func _on_window_closed():
	active_window = null

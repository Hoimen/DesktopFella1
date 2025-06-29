extends Node

# Desired aspect ratio: 16:9
const TARGET_ASPECT_RATIO := 16.0 / 9.0
var last_window_size := Vector2i.ZERO

func _process(_delta):
	var current_size = DisplayServer.window_get_size()
	if current_size != last_window_size:
		last_window_size = current_size
		_enforce_aspect_ratio(current_size)

func _enforce_aspect_ratio(size: Vector2i):
	var current_aspect = float(size.x) / float(size.y)
	
	if abs(current_aspect - TARGET_ASPECT_RATIO) > 0.01:
		# Calculate corrected width or height
		if current_aspect > TARGET_ASPECT_RATIO:
			# Too wide — reduce width
			size.x = int(size.y * TARGET_ASPECT_RATIO)
		else:
			# Too tall — reduce height
			size.y = int(size.x / TARGET_ASPECT_RATIO)
		
		DisplayServer.window_set_size(size)

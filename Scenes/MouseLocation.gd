extends Node

var time_accumulator := 0.0
var screen_size := Vector2.ZERO

func _ready() -> void:
	screen_size = DisplayServer.screen_get_size()
	print("Screen Size: ", screen_size)
	print("Left Wall (x = 0)")
	print("Right Wall (x = ", screen_size.x, ")")
	print("Top Wall (y = 0)")
	print("Bottom Wall (y = ", screen_size.y, ")")


func _process(delta: float) -> void:
	time_accumulator += delta
	if time_accumulator >= 1.0:
		var screen_pos = DisplayServer.mouse_get_position()
		print("Mouse Screen Position: ", screen_pos)
		time_accumulator = 0.0

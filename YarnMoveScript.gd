extends Node

const DAMPING_RATE := 1       # the a part in e^{-a t}
const FREQUENCY := 10.0            # the w part in sin(w t)
const BOUNCE_AMPLITUDE := 200.0    # the A part 
const MIN_AMPLITUDE := 0.1         # stop bouncing if smaller than this

var is_dragging := false
var bounce_start_time := 0.0
var bounce_amplitude := 0.0
var is_bouncing := false
var bounce_base_y := 0.0

func _process(delta):
	var window := get_window()
	var screen_size := Vector2(DisplayServer.screen_get_size())
	var mouse_pos := Vector2(DisplayServer.mouse_get_position())
	var window_size := Vector2(window.size)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_bouncing = false 

		if not is_dragging:
			var window_pos := Vector2(window.position)
			var window_rect := Rect2(window_pos, window_size)
			if window_rect.has_point(mouse_pos):
				is_dragging = true

		if is_dragging:
			var half_size := window_size * 0.5
			var new_pos := (mouse_pos - half_size).floor()
			window.position = Vector2i(new_pos)
	else:
		if is_dragging:
			is_dragging = false

			var window_pos := Vector2(window.position)
			var floor_y := screen_size.y - window_size.y


			is_bouncing = true
			bounce_start_time = 0.0
			bounce_base_y = floor_y
			bounce_amplitude = BOUNCE_AMPLITUDE
		elif is_bouncing:
			bounce_start_time += delta


			var t = bounce_start_time # use of T (might move this)
			var damping = exp(-DAMPING_RATE * t)      # e^{-a t}
			var oscillation = sin(FREQUENCY * t)      # sin(ω t)
			var y_offset = bounce_amplitude * damping * oscillation  
			# y(t) = e^{-a t} * sin(ω t) Oh my god

			# Window Y = floor Y in equation EXACTLY
			var new_y = bounce_base_y - y_offset

			if abs(y_offset) < MIN_AMPLITUDE:
				is_bouncing = false 
				new_y = bounce_base_y
				#if min amplitude var is hit then set to y 


			window.position = Vector2i(Vector2(window.position.x, new_y).floor())
		else:
			# Forget the stupid boncing set right back to the floor otherwise known as Y
			var floor_y = screen_size.y - window_size.y
			window.position.y = int(floor_y)

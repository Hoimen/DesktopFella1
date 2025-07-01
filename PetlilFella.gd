extends Node2D

@export var petting_area: PanelContainer
@export var feedback_sprite: Sprite2D
@export var petting_threshold := 30.0
@export var required_strokes := 3
@export var stroke_timeout := 1.0 # max seconds allowed between direction changes
@export var petting_show_duration := 2.0 # seconds to show sprite after petting

var last_mouse_pos := Vector2.ZERO
var last_direction := 0
var stroke_count := 0
var stroke_timer := 0.0

var is_petting := false
var petting_timer := 0.0

func _ready():
	if feedback_sprite:
		feedback_sprite.visible = false
	else:
		push_error("feedback_sprite is not assigned!")

func _process(delta):
	if not petting_area or not feedback_sprite:
		return

	var local_mouse_pos = petting_area.get_local_mouse_position()
	var area_rect = Rect2(Vector2.ZERO, petting_area.size)

	if area_rect.has_point(local_mouse_pos):
		# Mouse is inside the petting area
		var mouse_pos = get_viewport().get_mouse_position()
		var delta_x = mouse_pos.x - last_mouse_pos.x

		if abs(delta_x) > petting_threshold:
			var current_direction = sign(delta_x)

			if current_direction != last_direction and last_direction != 0:
				stroke_count += 1
				stroke_timer = 0.0
				print("Stroke count: ", stroke_count)

				if stroke_count >= required_strokes:
					trigger_petting()
					stroke_count = 0
			else:
				# keep same direction, reset timer
				stroke_timer = 0.0

			last_direction = current_direction

		stroke_timer += delta
		if stroke_timer > stroke_timeout:
			stroke_count = 0
			stroke_timer = 0.0
			last_direction = 0

		last_mouse_pos = mouse_pos
	else:
		# If we want to reset stroke progress when leaving the area, do it here:
		stroke_count = 0
		stroke_timer = 0.0
		last_direction = 0

	# Handle petting timer regardless of mouse position
	if is_petting:
		petting_timer -= delta
		if petting_timer <= 0.0:
			reset_petting()

func trigger_petting():
	is_petting = true
	petting_timer = petting_show_duration
	feedback_sprite.visible = true
	print("Petting activated!")

func reset_petting():
	is_petting = false
	feedback_sprite.visible = false
	stroke_count = 0
	stroke_timer = 0.0
	last_direction = 0
	last_mouse_pos = get_viewport().get_mouse_position()

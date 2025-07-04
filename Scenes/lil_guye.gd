extends Node

@export var held_up: Sprite2D
@export var held_down: Sprite2D
@export var held_left: Sprite2D
@export var held_right: Sprite2D
@export var normal_hold: Sprite2D
@export var content_root: Node
@export var drag_panel_container: PanelContainer
@export var drag_when_held_panel: PanelContainer

const MOVEMENT_THRESHOLD := 5.0
const INACTIVITY_TIMEOUT := 0.3
const GRAVITY := 5000.0
const MAX_FALL_SPEED := 3000.0

@export var min_window_width: int = 400

var timer := 0.0
var last_mouse_pos := Vector2.ZERO
var time_since_last_move := 0.0
var fall_speed := 0.0
var is_falling := false
var is_holding_window := false

var original_window_size: Vector2
var drag_window_center: Vector2
var drag_offset_to_center: Vector2

func _ready():
	_hide_all_sprites()
	last_mouse_pos = Vector2(DisplayServer.mouse_get_position())

	var window = get_window()
	original_window_size = Vector2(window.size)
	drag_window_center = Vector2(window.position) + window.size * 0.5
	drag_offset_to_center = Vector2.ZERO

	if drag_panel_container:
		drag_panel_container.gui_input.connect(_on_drag_panel_gui_input)

func _on_drag_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_holding_window = true

				var window = get_window()
				var mouse_pos = Vector2(DisplayServer.mouse_get_position())

				drag_window_center = Vector2(window.position) + window.size * 0.5
				drag_offset_to_center = mouse_pos - drag_window_center
			else:
				is_holding_window = false

func _process(delta):
	timer += delta
	time_since_last_move += delta

	var mouse_pos := Vector2(DisplayServer.mouse_get_position())
	var window = get_window()
	var usable_rect := DisplayServer.screen_get_usable_rect()

	if is_holding_window:
		# update center based on dragging
		drag_window_center = mouse_pos - drag_offset_to_center

		# Clamp center horizontally only
		var half_width = window.size.x * 0.5
		drag_window_center.x = clamp(
			drag_window_center.x,
			usable_rect.position.x + half_width,
			usable_rect.position.x + usable_rect.size.x - half_width
		)

		# Instantly shrink window width
		window.size.x = min_window_width

		# Compute window position so center stays fixed
		window.position = Vector2i((drag_window_center - window.size * 0.5).floor())

		# Allow vertical motion freely
		var delta_pos = mouse_pos - last_mouse_pos
		if delta_pos.length() >= MOVEMENT_THRESHOLD:
			_update_direction_sprite(delta_pos)
			time_since_last_move = 0.0

		fall_speed = 0.0
		is_falling = false

		# keep window horizontally on screen
		_keep_window_on_screen(window, usable_rect)

		# Shift panel left to fake center shrinking
		_update_drag_when_held_shift(window)
	else:
		# compute center before restoring
		var center_x = window.position.x + window.size.x * 0.5

		# restore width
		window.size.x = original_window_size.x

		# reposition to keep center
		window.position.x = int(center_x - window.size.x * 0.5)

		# keep window horizontally on screen
		_keep_window_on_screen(window, usable_rect)

		# reset panel shift
		_update_drag_when_held_shift(window)

		# gravity drop
		if window.position.y + window.size.y < usable_rect.position.y + usable_rect.size.y:
			fall_speed = min(fall_speed + GRAVITY * delta, MAX_FALL_SPEED)
			var new_y = window.position.y + int(fall_speed * delta)

			new_y = clamp(
				new_y,
				usable_rect.position.y,
				usable_rect.position.y + usable_rect.size.y - window.size.y
			)

			window.position.y = new_y
			is_falling = true

			_hide_all_sprites()
			if held_down:
				held_down.visible = true
		else:
			window.position.y = usable_rect.position.y + usable_rect.size.y - window.size.y
			fall_speed = 0.0
			is_falling = false
			_hide_all_sprites()

	# Hide sprites if inactive
	if time_since_last_move >= INACTIVITY_TIMEOUT and not is_falling:
		_hide_all_sprites()

	# Show normal_hold sprite if dragging
	if is_holding_window and not _any_direction_sprite_visible():
		if normal_hold:
			normal_hold.visible = true
	else:
		if normal_hold:
			normal_hold.visible = false

	_update_content_visibility()

	last_mouse_pos = mouse_pos

func _keep_window_on_screen(window, usable_rect):
	# Clamp horizontally only
	if window.position.x < usable_rect.position.x:
		window.position.x = usable_rect.position.x

	var right = window.position.x + window.size.x
	if right > usable_rect.position.x + usable_rect.size.x:
		window.position.x = usable_rect.position.x + usable_rect.size.x - window.size.x

func _update_drag_when_held_shift(window):
	if not drag_when_held_panel:
		return

	var lost_width = original_window_size.x - window.size.x
	var half_shift = lost_width * 0.5

	drag_when_held_panel.position.x = -half_shift

func _hide_all_sprites():
	for sprite in [held_up, held_down, held_left, held_right, normal_hold]:
		if sprite:
			sprite.visible = false

func _update_direction_sprite(delta_pos: Vector2):
	_hide_all_direction_sprites()

	if abs(delta_pos.x) > abs(delta_pos.y):
		if delta_pos.x > 0 and held_right:
			held_right.visible = true
		elif delta_pos.x < 0 and held_left:
			held_left.visible = true
	else:
		if delta_pos.y > 0 and held_down:
			held_down.visible = true
		elif delta_pos.y < 0 and held_up:
			held_up.visible = true

func _hide_all_direction_sprites():
	for sprite in [held_up, held_down, held_left, held_right]:
		if sprite:
			sprite.visible = false

func _any_direction_sprite_visible() -> bool:
	return (
		(held_up and held_up.visible) or
		(held_down and held_down.visible) or
		(held_left and held_left.visible) or
		(held_right and held_right.visible)
	)

func _update_content_visibility():
	if not content_root:
		return

	var any_sprite_visible := _any_direction_sprite_visible() or (normal_hold and normal_hold.visible)
	content_root.visible = not any_sprite_visible

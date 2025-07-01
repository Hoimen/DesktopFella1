extends Node

@export var drop_sprite: Sprite2D


func _ready():
	if drop_sprite:
		drop_sprite.visible = false

func _files_dropped(files: PackedStringArray, screen_position: Vector2):
	if files.size() > 0:
		var path = files[0]
		if DirAccess.dir_exists_absolute(path):
			if drop_sprite:
				drop_sprite.global_position = screen_position
				drop_sprite.visible = true
			print("Folder dropped: ", path)

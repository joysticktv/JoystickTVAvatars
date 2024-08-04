extends Node

@onready var _settingsButton = $SettingsButton

func _ready():
	var viewport_size = get_viewport().size
	var node_size = _settingsButton.size
	var top_right_position = Vector2(viewport_size.x - node_size.x, 0)
	top_right_position += Vector2(-10, 10)
	_settingsButton.position = top_right_position

func _on_exit_button_pressed():
	get_tree().change_scene_to_file(Global.previous_scene_file_path)

func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://screens/Settings/Settings.tscn")

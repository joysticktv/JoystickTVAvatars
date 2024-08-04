extends Node2D

@onready var _backButton = $VBoxContainer/BackButton

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport_size = get_viewport().size
	var node_size = $Container.size
	var center_position = (Vector2(viewport_size) - node_size) / 2.0
	$Container.position = center_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_back_button_button_up():
	get_tree().change_scene_to_file(Global.previous_scene_file_path)

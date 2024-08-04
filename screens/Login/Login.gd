extends Node2D

@onready var _clientIDLineEdit = $Container/ClientIdLineEdit
@onready var _clientSecretLineEdit = $Container/ClientSecretLineEdit
@onready var _connectButton = $Container/ConnectButton

const CONFIG_FILE_PATH = "user://credentials.cfg"

func _ready():
	get_viewport().transparent_bg = true
	
	var viewport_size = get_viewport().size
	var node_size = $Container.size
	var center_position = (Vector2(viewport_size) - node_size) / 2.0
	$Container.position = center_position
	
	load_credentials()

func _process(delta):
	pass

func _on_connect_button_button_up():
	Global.client_id = _clientIDLineEdit.text
	Global.client_secret = _clientSecretLineEdit.text
	Global.previous_scene_file_path = get_tree().current_scene.scene_file_path
	save_credentials()
	get_tree().change_scene_to_file("res://screens/Game/Game.tscn")

func _on_settings_button_pressed():
	Global.previous_scene_file_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://screens/Settings/Settings.tscn")

func save_credentials():
	var config = ConfigFile.new()
	config.set_value("Credentials", "client_id", Global.client_id)
	config.set_value("Credentials", "client_secret", Global.client_secret)
	config.save(CONFIG_FILE_PATH)

func load_credentials():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE_PATH)
	if err == OK:
		Global.client_id = config.get_value("Credentials", "client_id", "")
		Global.client_secret = config.get_value("Credentials", "client_secret", "")
		_clientIDLineEdit.text = Global.client_id
		_clientSecretLineEdit.text = Global.client_secret
	else:
		print("Failed to load credentials. Error code: ", err)

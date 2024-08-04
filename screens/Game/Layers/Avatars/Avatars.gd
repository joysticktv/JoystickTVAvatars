extends Node2D

const maxNumberOfChatMessages = 50

var players = []

@export var playerScene : PackedScene

func _ready():
	EventBus.connect("message_received", _on_message_received)
	EventBus.connect("enter_stream", _on_add_viewer)
	EventBus.connect("test_chat_message", _on_test_chat_message)
	EventBus.connect("test_enter_stream", _on_test_enter_stream)
	
func _on_test_chat_message():
	var player = players.pick_random()
	if player:
		var text = _get_random_sentence()
		if text == "!avatar jump":
			player.jump()
		else:
			player.set_chat_message(text)
	
func _on_test_enter_stream():
	var random_username = "user%d" % (randi() % 10)
	add_viewer(random_username)

func _on_message_received(username, message):
	# TODO: Should not be random
	var player = players.pick_random()
	if player:
		if message == "!avatar jump":
			player.jump()
		else:
			player.set_chat_message(message)

func _on_add_viewer(username):
	add_viewer(username)

func _cleanup():
	pass

func add_viewer(username):
	var new_player = playerScene.instantiate()
	players.append(new_player)
	var viewport_size = get_viewport().size
	var center_position = (Vector2(viewport_size)) / 2.0
	var avatarTypes = ["human", "goblin"]
	randomize()
	var typeIndex = randi() % avatarTypes.size()
	var randomType = avatarTypes[typeIndex]
	new_player.set_type(randomType)
	new_player.position = center_position
	add_child(new_player)
	new_player.set_username(username)

func _get_random_sentence() -> String:
	var sentences = [
		"!avatar jump",
		"My code doesn't work, I have no idea why.",
		"My code works, I have no idea why.",
		"I don't always test my code, but when I do, I do it in production.",
		"There are 10 types of people: those who understand binary, and those who don't.",
		"Why do programmers prefer dark mode? Because light attracts bugs.",
		"I told a UDP joke, but I don't know if you got it.",
	]
	return sentences[randi() % sentences.size()]

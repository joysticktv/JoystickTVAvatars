extends Button

func _ready():
	pass

func _process(delta):
	pass

func _on_pressed():
	EventBus.emit_signal("test_chat_message")

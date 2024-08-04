extends Node

const WS_HOST = "wss://joystick.tv/cable"

var websocket = WebSocketPeer.new()
var connected = false

signal message_received(message)
signal ping_received(message)

func _ready():
	var access_token = Marshalls.utf8_to_base64(Global.client_id + ":" + Global.client_secret)
	var url = WS_HOST + "?token=" + access_token
	
	var protocols = ["actioncable-v1-json"]
	websocket.set_supported_protocols(PackedStringArray(protocols))

	var headers = ["User-Agent: JoystickTVAvatars/1.0"]
	websocket.set_handshake_headers(PackedStringArray(headers))
	
	var err = websocket.connect_to_url(url)
	if err != OK:
		print("Failed to initiate connection. Error code: ", err)
		print("Error description: ", error_string(err))
		return

func _gateway_identifier():
	return JSON.stringify({ "channel": "GatewayChannel" })

func _process(delta):
	websocket.poll()
	var state = websocket.get_ready_state()
	match state:
		WebSocketPeer.STATE_CONNECTING:
			print("Still connecting... Elapsed time: ")
			pass
		WebSocketPeer.STATE_OPEN:
			if not connected:
				send_subscribe_message()
			while websocket.get_available_packet_count():
				handle_message(websocket.get_packet().get_string_from_utf8())
		WebSocketPeer.STATE_CLOSING:
			print("WebSocket is closing...")
		WebSocketPeer.STATE_CLOSED:
			var code = websocket.get_close_code()
			var reason = websocket.get_close_reason()
			print("WebSocket closed at: ", Time.get_datetime_string_from_system())
			set_process(false)

func send_subscribe_message():
	var message = {
		"command": "subscribe",
		"identifier": _gateway_identifier()
	}
	send_message(message)

func send_message(message):
	websocket.send_text(JSON.stringify(message))

func handle_message(data):
	var received_message = JSON.parse_string(data)
	if received_message == null:
		print("Failed to parse message: ", data)
		return
	
	if received_message.has("identifier"):
		if received_message.has("type"):
			match received_message["type"]:
				"welcome":
					print("Received welcome message")
				"ping":
					handle_ping(received_message)
				"confirm_subscription":
					connected = true
					print("Subscription confirmed")
				"reject_subscription":
					print("Subscription rejected")
					
		if received_message.has("message"):
			match received_message["message"]["type"]:
				# leave_stream
				# ViewerCountUpdated
				"enter_stream":
					EventBus.emit_signal("enter_stream", received_message["message"]["text"])
				"new_message":
					EventBus.emit_signal("message_received", received_message["message"]["author"]["username"], received_message["message"]["text"])		
	else:
		handle_chat_message(received_message)

func handle_ping(message):
	emit_signal("ping_received", message)

func handle_chat_message(message):
	EventBus.emit_signal("message_received", message)

func _exit_tree():
	if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var close_message = {
			"command": "unsubscribe",
			"identifier": _gateway_identifier
		}
		send_message(close_message)
	websocket.close()

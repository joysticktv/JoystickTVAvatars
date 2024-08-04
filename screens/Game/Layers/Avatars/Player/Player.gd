extends CharacterBody2D

@export var explosionParticle : PackedScene
@export var message_timer: Timer

const JUMP_VELOCITY = -400.0

var target_speed : float
var current_speed : float = 0
var acceleration : float = 10
var direction = Vector2.RIGHT
var change_interval : float
var elapsed_time = 0.0
var left_boundary = 0
var right_boundary = 1280
var min_x : float
var max_x : float
var jumping = false
var _sprite : AnimatedSprite2D
var avatarType = "human"
var is_paused = false
var pause_timer : Timer
var pause_duration = 0.0
var next_pause_time = 0.0
var playerInstance : CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	randomize()
	
	message_timer = $Timer
	message_timer.timeout.connect(Callable(self, "_on_message_timer_timeout"))
	
	_setup_avatar()
	
	if _sprite:
		_sprite.play("walking")
	
	right_boundary = get_viewport().size.x
	
	# Randomize initial direction
	direction = Vector2(randf_range(-1, 1), 0).normalized()
	_update_sprite_orientation()
	
	# Randomize target speed
	target_speed = randf_range(200, 1000)
	
	# Randomize change interval (longer intervals)
	change_interval = randf_range(3.0, 8.0)
	
	# Randomize movement range
	var range_width = randf_range(100, 300)
	min_x = randf_range(left_boundary, right_boundary - range_width)
	max_x = min_x + range_width
	
	# Initialize pause timer
	pause_timer = Timer.new()
	add_child(pause_timer)
	pause_timer.timeout.connect(Callable(self, "_on_pause_timeout"))
	set_next_pause_time()

func _setup_avatar():
	var scene_path = "res://screens/Game/Layers/Avatars/Player/Human/Avatar.tscn"
	if avatarType == "goblin":
		scene_path = "res://screens/Game/Layers/Avatars/Player/Goblin/Avatar.tscn"
	
	var scene = load(scene_path)
	playerInstance = scene.instantiate()
	add_child(playerInstance)
	_sprite = playerInstance.get_node("AnimatedSprite")

func set_type(type_of : String):
	avatarType = type_of

func set_username(new_username: String):
	if playerInstance and playerInstance.has_node("Username"):
		playerInstance.get_node("Username").text = new_username

func set_chat_message(new_chat_message: String):
	if playerInstance and playerInstance.has_node("PanelContainer"):
		playerInstance.get_node("PanelContainer/ChatMessage").visible = true
		playerInstance.get_node("PanelContainer/ChatMessage").text = new_chat_message
		playerInstance.get_node("PanelContainer/GPUParticles2D").emitting = true
		message_timer.stop()
		message_timer.start(3.0)

func _on_message_timer_timeout():
	playerInstance.get_node("PanelContainer/ChatMessage").visible = false

func _process(delta):
	elapsed_time += delta
	
	if elapsed_time > change_interval:
		elapsed_time = 0
		_change_direction()
		change_interval = randf_range(3.0, 8.0)
	
	# Check if it's time to pause
	if not is_paused and elapsed_time > next_pause_time:
		_pause()
	
	if is_paused:
		return  # Skip the movement logic while paused

	# Smoothly adjust current_speed towards target_speed
	current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	
	var velocity = direction * current_speed * delta
	position += velocity
	
	if position.x < min_x or position.x > max_x:
		_change_direction()
	
	position.x = clamp(position.x, min_x, max_x)

	# Update animation speed based on movement speed
	if _sprite:
		_sprite.speed_scale = current_speed / 30.0
		
func _change_direction():
	direction = Vector2(randf_range(-1, 1), 0).normalized()
	_update_sprite_orientation()
	
	# Small chance to change target speed
	if randf() < 0.3:
		target_speed = randf_range(10, 30)

func _update_sprite_orientation():
	if _sprite:
		_sprite.flip_h = direction.x < 0

func jump():
	jumping = true

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY * randf_range(0.9, 1.1)
	else:
		jumping = false
	
	move_and_slide()

func _pause():
	is_paused = true
	pause_duration = randf_range(2.0, 5.0)  # Longer pause duration between 2 and 5 seconds
	pause_timer.start(pause_duration)
	if _sprite:
		_sprite.play("idle")  # Switch to idle animation if you have one

func _on_pause_timeout():
	is_paused = false
	set_next_pause_time()
	if _sprite:
		_sprite.play("walking")

func set_next_pause_time():
	next_pause_time = randf_range(3.0, 8.0)  # Shorter time between pauses (3 to 8 seconds)

extends Label

func _ready():
	var new_sb = StyleBoxFlat.new()
	new_sb.bg_color = Color.WHITE
	#new_sb.set_content_margin_all(5)
	new_sb.expand_margin_top = 5.0
	new_sb.expand_margin_right = 10.0
	new_sb.expand_margin_bottom = 5.0
	new_sb.expand_margin_left = 10.0
	new_sb.set_border_width_all(0)
	new_sb.set_corner_radius_all(20)
	new_sb.skew = Vector2(.02, 0)
	
	add_theme_stylebox_override("normal", new_sb)
	add_theme_color_override("font_color", Color.BLACK)
	
	var emitter = get_node("../../Websocket")
	if emitter:
		print("Emitter found, connecting signal...")
		emitter.message_received.connect(_on_message_received)
	else:
		print("Emitter not found")

func _process(delta):
	pass

func _on_message_received(message: Dictionary):
	if message["message"]["type"] == "new_message":
		_run_explosion()
		var text = message["message"]["text"]
		self.text = text

func _run_explosion():
	var particles_material = preload("res://screens/Game/Layers/Avatars/Player/ExplosionParticleProcessMaterial.tres")
	var particles = GPUParticles2D.new()
	particles.process_material = particles_material	
	particles.one_shot = true
	particles.emitting = true
	particles.finished.connect(_on_particles_finished.bind([particles]))
	add_child(particles)
	
func _on_particles_finished(particles):
	# Remove the Particles2D node from the tree
	particles.queue_free()

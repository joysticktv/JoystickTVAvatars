extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var world_boundary: WorldBoundaryShape2D = collision_shape.shape

func _ready():
	# Connect to the window resize signal
	get_tree().root.size_changed.connect(update_boundary_position)
	
	# Initial position update
	update_boundary_position()

func update_boundary_position():
	# Get the current viewport size
	var viewport_size = get_viewport_rect().size
	
	# Set the position to the bottom of the viewport
	position = Vector2(viewport_size.x / 2, viewport_size.y)
	
	# Update the shape's distance
	world_boundary.distance = 0

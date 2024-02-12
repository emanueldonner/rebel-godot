extends CharacterBody2D

@onready var tile_map = $"../TileMap"

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var target_position: Vector2
var is_moving: bool
var speed: int = 50
var move_limit: int = 4


# Called when the node enters the scene tree for the first time.
func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(16,16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar_grid.update()
	
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)
			
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)
	
func _input(event):
	if event is InputEventMouseMotion and !is_moving:
		var path = astar_grid.get_point_path(
			tile_map.local_to_map(target_position),
			tile_map.local_to_map(get_global_mouse_position())
		)

		# Limit the indication path by slicing it to the move limit
		if path.size() > move_limit:
			current_point_path = path.slice(0, move_limit + 1)
		else:
			current_point_path = path
		
		for i in current_point_path.size():
			current_point_path[i] = current_point_path[i] + Vector2(8,8)

	if event.is_action_pressed("move") and !is_moving:
		var id_path = astar_grid.get_id_path(
			tile_map.local_to_map(global_position),
			tile_map.local_to_map(get_global_mouse_position())
		)

		# Limit the actual movement path
		if id_path.size() > move_limit + 1:  # +1 because we slice starting from 1
			current_id_path = id_path.slice(1, move_limit + 1)
		else:
			current_id_path = id_path.slice(1)
		
		
		
func _physics_process(_delta):
	if current_id_path.is_empty():
		is_moving = false
		velocity = Vector2.ZERO
	else:
		if !is_moving:
			target_position = tile_map.map_to_local(current_id_path.front())
			is_moving = true

		var direction = (target_position - global_position).normalized()
		velocity = direction * speed

		if global_position.distance_to(target_position) < speed * _delta:
				global_position = target_position  # Snap to the target position to avoid overshooting
				current_id_path.pop_front()
				if current_id_path.is_empty():
						is_moving = false
						velocity = Vector2.ZERO
				else:
						target_position = tile_map.map_to_local(current_id_path.front())

	# Move the player using move_and_slide
	move_and_slide()
		

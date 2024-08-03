extends Node3D

const TREE = preload("res://entities/resources/tree/tree.tscn")
const ROCK = preload("res://entities/resources/rock/rock.tscn")
const TREE_AMOUNT = 50
const ROCK_AMOUNT = 50
const WALL_PADDING = 20

@onready var csg_box_3d = $CSGBox3D
@onready var resources = $Resources
@onready var walls = $Walls

func _ready():
	for child in resources.get_children(): child.queue_free()
	for child in walls.get_children(): child.queue_free()
	
	generate_trees()
	generate_walls()

func generate_trees():
	for i in TREE_AMOUNT:
		var tree = TREE.instantiate()
		var cap_x = csg_box_3d.size.x - WALL_PADDING
		var cap_z = csg_box_3d.size.z - WALL_PADDING
		tree.position = Vector3(
			csg_box_3d.position.x + randf_range(0, cap_x) - cap_x / 2,
			csg_box_3d.position.y + csg_box_3d.size.y / 2,
			csg_box_3d.position.z + randf_range(0, cap_z) - cap_z / 2
		)
		tree.scale *= randf_range(0.75, 1.25)
		resources.add_child(tree)

func generate_walls():
	var curve = Curve3D.new()
	curve.add_point(csg_box_3d.size / 2)
	curve.add_point(Vector3(csg_box_3d.size.x / 2, csg_box_3d.size.y / 2, csg_box_3d.size.z / -2))
	curve.add_point(csg_box_3d.size / -2)
	curve.add_point(Vector3(csg_box_3d.size.x / -2, csg_box_3d.size.y / 2, csg_box_3d.size.z / 2))
	curve.add_point(csg_box_3d.size / 2)
	
	var length = curve.get_baked_length()
	for i in range(ROCK_AMOUNT):
		var t = float(i) / float(ROCK_AMOUNT - 1)
		var distance = t * length
		
		var rock = ROCK.instantiate()
		rock.position = curve.sample_baked(distance)
		rock.scale *= randf_range(8.0, 12.0)
		rock.rotate_y(randf_range(0.0, 2.0 * PI))
		rock.rotate_x(randf_range(-1.0, 1.0))
		rock.rotate_z(randf_range(-1.0, 1.0))
		walls.add_child(rock)

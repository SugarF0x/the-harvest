extends Node3D

const TREE = preload("res://entities/resources/tree/tree.tscn")
const TREE_AMOUNT = 20

@onready var csg_box_3d = $CSGBox3D
@onready var resources = $Resources

func _ready():
	for child in resources.get_children():
		child.queue_free()
	
	for i in TREE_AMOUNT:
		var tree = TREE.instantiate()
		tree.position.y = csg_box_3d.position.y + csg_box_3d.size.y / 2
		tree.position.x = csg_box_3d.position.x + randf_range(0, csg_box_3d.size.x) - csg_box_3d.size.x / 2
		tree.position.z = csg_box_3d.position.z + randf_range(0, csg_box_3d.size.z) - csg_box_3d.size.z / 2
		tree.scale *= randf_range(0.75, 1.25)
		resources.add_child(tree)

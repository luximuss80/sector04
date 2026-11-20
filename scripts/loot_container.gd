extends Interactable

@export var kind: String = "barrel"
@export var action_word: String = "Обыскать"
@export var loot_pool: Array[String] = ["scrap", "canned_food", "water", "bandage"]
@export var rolls: int = 2

var _looted: bool = false


func get_prompt() -> String:
	return "" if _looted else action_word


func interact(_player: Node3D) -> void:
	if _looted:
		return
	_looted = true
	for i in rolls:
		Game.add_item(loot_pool.pick_random())


func _ready() -> void:
	if kind == "crate":
		_build_crate()
	else:
		_build_barrel()


func _build_barrel() -> void:
	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.48
	cylinder.bottom_radius = 0.52
	cylinder.height = 1.15
	cylinder.radial_segments = 10
	mesh.mesh = cylinder
	mesh.position = Vector3(0, 0.575, 0)
	mesh.material = _solid(Color(0.4, 0.24, 0.14))
	add_child(mesh)
	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.46
	ring_mesh.outer_radius = 0.55
	ring.mesh = ring_mesh
	ring.position = Vector3(0, 0.75, 0)
	ring.material = _solid(Color(0.25, 0.16, 0.1))
	add_child(ring)
	_add_collision(Vector3(1.0, 1.15, 1.0), Vector3(0, 0.575, 0))


func _build_crate() -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.95, 0.75, 0.95)
	mesh.mesh = box
	mesh.position = Vector3(0, 0.375, 0)
	mesh.material = _solid(Color(0.5, 0.38, 0.22))
	add_child(mesh)
	var lid := MeshInstance3D.new()
	var lid_mesh := BoxMesh.new()
	lid_mesh.size = Vector3(1.05, 0.12, 1.05)
	lid.mesh = lid_mesh
	lid.position = Vector3(0, 0.8, 0)
	lid.material = _solid(Color(0.38, 0.28, 0.16))
	add_child(lid)
	_add_collision(Vector3(1.05, 0.9, 1.05), Vector3(0, 0.45, 0))


func _add_collision(size: Vector3, pos: Vector3) -> void:
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position = pos
	add_child(collision)


func _solid(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	return mat

extends Interactable

const COLORS: Dictionary = {
	"scrap": Color(0.55, 0.5, 0.42),
	"canned_food": Color(0.8, 0.65, 0.2),
	"water": Color(0.25, 0.5, 0.8),
	"keycard": Color(0.85, 0.2, 0.2),
	"bandage": Color(0.9, 0.9, 0.85),
}

@export var item_id: String = "scrap"

var _mesh: MeshInstance3D
var _base_y: float = 0.0
var _time: float = 0.0


func _ready() -> void:
	prompt = "Взять"
	_build()


func _process(delta: float) -> void:
	if _mesh == null:
		return
	_time += delta
	_mesh.rotation.y += delta * 1.2
	_mesh.position.y = _base_y + sin(_time * 2.5) * 0.08


func interact(_player: Node3D) -> void:
	Game.add_item(item_id)
	queue_free()


func _build() -> void:
	_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	match item_id:
		"keycard":
			box.size = Vector3(0.32, 0.04, 0.2)
		"canned_food":
			box.size = Vector3(0.22, 0.3, 0.22)
		_:
			box.size = Vector3(0.3, 0.3, 0.3)
	_mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = COLORS.get(item_id, Color.WHITE)
	mat.roughness = 0.8
	_mesh.material = mat
	_mesh.position = Vector3(0, 0.55, 0)
	add_child(_mesh)
	_base_y = _mesh.position.y
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.7, 0.9, 0.7)
	collision.shape = shape
	collision.position = Vector3(0, 0.45, 0)
	add_child(collision)

extends Interactable

const DOOR_COLOR := Color(0.4, 0.2, 0.15)
const FRAME_COLOR := Color(0.45, 0.45, 0.42)

var is_open: bool = false

var _panel: MeshInstance3D
var _collision: CollisionShape3D


func get_prompt() -> String:
	return "" if is_open else "Открыть"


func interact(_player: Node3D) -> void:
	if is_open:
		return
	if Game.has_item("keycard"):
		is_open = true
		Game.complete_quest("bunker")
		Game.post_message("Дверь бункера открыта")
		_open()
	else:
		Game.post_message("Заперто. Нужна ключ-карта.")


func _ready() -> void:
	_panel = MeshInstance3D.new()
	var panel_mesh := BoxMesh.new()
	panel_mesh.size = Vector3(2.0, 2.8, 0.3)
	_panel.mesh = panel_mesh
	_panel.position = Vector3(0, 1.4, 0)
	var door_mat := StandardMaterial3D.new()
	door_mat.albedo_color = DOOR_COLOR
	door_mat.roughness = 0.6
	door_mat.metallic = 0.4
	_panel.material = door_mat
	add_child(_panel)
	_add_frame_box(Vector3(0.35, 3.4, 0.6), Vector3(-1.2, 1.6, 0))
	_add_frame_box(Vector3(0.35, 3.4, 0.6), Vector3(1.2, 1.6, 0))
	_add_frame_box(Vector3(2.75, 0.35, 0.6), Vector3(0, 3.4, 0))
	var lamp := MeshInstance3D.new()
	var lamp_mesh := BoxMesh.new()
	lamp_mesh.size = Vector3(0.15, 0.15, 0.15)
	lamp.mesh = lamp_mesh
	lamp.position = Vector3(0, 3.05, -0.3)
	var lamp_mat := StandardMaterial3D.new()
	lamp_mat.albedo_color = Color(1, 0.15, 0.1)
	lamp_mat.emission_enabled = true
	lamp_mat.emission = Color(1, 0.1, 0.05)
	lamp_mat.emission_energy_multiplier = 2.5
	lamp.material = lamp_mat
	add_child(lamp)
	_collision = CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.2, 3.0, 0.5)
	_collision.shape = shape
	_collision.position = Vector3(0, 1.5, 0)
	add_child(_collision)


func _open() -> void:
	_collision.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(_panel, "position:y", -1.6, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func _add_frame_box(size: Vector3, pos: Vector3) -> void:
	var frame := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	frame.mesh = mesh
	frame.position = pos
	frame.material = _frame_material()
	add_child(frame)


func _frame_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = FRAME_COLOR
	mat.roughness = 1.0
	return mat

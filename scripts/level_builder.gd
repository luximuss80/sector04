extends Node3D

const LootContainerScene: PackedScene = preload("res://scenes/objects/loot_container.tscn")
const PickupScene: PackedScene = preload("res://scenes/objects/item_pickup.tscn")
const BunkerDoorScene: PackedScene = preload("res://scenes/objects/bunker_door.tscn")

const WOOD := Color(0.45, 0.33, 0.2)
const WOOD_DARK := Color(0.28, 0.2, 0.12)
const TRUNK := Color(0.33, 0.24, 0.15)
const METAL_DARK := Color(0.3, 0.32, 0.34)
const RUST := Color(0.45, 0.27, 0.16)
const CONCRETE := Color(0.52, 0.52, 0.5)
const WINDOW := Color(0.08, 0.1, 0.11)
const FOLIAGE := Color(0.15, 0.28, 0.14)
const FOLIAGE_LIGHT := Color(0.19, 0.34, 0.16)

var _mats: Dictionary = {}


func _ready() -> void:
	_build_ground()
	_build_forest_base()
	_build_wasteland()
	_build_borders()


func _build_ground() -> void:
	_box(Vector3(200, 1, 96), Vector3(0, -0.5, -66), Color(0.23, 0.31, 0.19), true)
	_box(Vector3(200, 1, 30), Vector3(0, -1.4, -3), Color(0.36, 0.34, 0.27), true)
	_box(Vector3(200, 1, 112), Vector3(0, -0.5, 68), Color(0.58, 0.51, 0.39), true)
	var water := _box(Vector3(200, 0.8, 30), Vector3(0, -0.35, -3), Color(0.16, 0.32, 0.4))
	water.material = _mat_alpha(Color(0.16, 0.32, 0.4), 0.75)
	_box_rot(Vector3(6, 0.3, 7), Vector3(-46, -0.42, -21.5), Vector3(0.13, 0, 0), Color(0.5, 0.44, 0.34), true)
	_box_rot(Vector3(6, 0.3, 7), Vector3(20, -0.42, 15.5), Vector3(-0.13, 0, 0), Color(0.55, 0.48, 0.37), true)


func _build_forest_base() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for i in 24:
		var pos := Vector3(rng.randf_range(-75.0, 75.0), 0.0, rng.randf_range(-105.0, -26.0))
		if pos.distance_to(Vector3(-30, 0, -46)) < 12.0:
			continue
		if absf(pos.x + 16.0) < 5.0 and pos.z > -40.0:
			continue
		_tree(pos, rng.randf_range(0.8, 1.4))
	_build_house()
	_build_campfire()
	_build_bridge()
	_container(Vector3(-31, 0.4, -48), "crate", "Открыть", 2)
	_container(Vector3(-25.5, 0, -44.5), "barrel", "Обыскать", 2)
	_container(Vector3(-34.5, 0, -42), "barrel", "Обыскать", 2)
	_container(Vector3(-24, 0, -50), "barrel", "Обыскать", 2)
	_pickup(Vector3(-29.5, 0.55, -49.5), "canned_food")
	_pickup(Vector3(-31.5, 0.55, -43.5), "water")


func _build_house() -> void:
	var hx := -30.0
	var hz := -46.0
	_box(Vector3(8, 0.4, 7), Vector3(hx, 0.2, hz), Color(0.35, 0.25, 0.16), true)
	_box(Vector3(8, 2.8, 0.3), Vector3(hx, 1.8, hz - 3.35), WOOD, true)
	_box(Vector3(4.4, 2.8, 0.3), Vector3(hx - 1.8, 1.8, hz + 3.35), WOOD, true)
	_box(Vector3(2.0, 2.8, 0.3), Vector3(hx + 3.0, 1.8, hz + 3.35), WOOD, true)
	_box(Vector3(0.3, 2.8, 6.7), Vector3(hx - 3.85, 1.8, hz), WOOD, true)
	_box(Vector3(0.3, 2.8, 6.7), Vector3(hx + 3.85, 1.8, hz), WOOD, true)
	_box_rot(Vector3(5.2, 0.25, 7.8), Vector3(hx - 1.7, 3.7, hz), Vector3(0, 0, 0.55), WOOD_DARK, true)
	_box_rot(Vector3(5.2, 0.25, 7.8), Vector3(hx + 1.7, 3.7, hz), Vector3(0, 0, -0.55), WOOD_DARK, true)
	_cyl(0.22, 2.2, Vector3(hx - 2.4, 3.9, hz - 1.8), METAL_DARK)
	_box(Vector3(0.15, 1.0, 1.4), Vector3(hx - 4.0, 1.9, hz), WINDOW)


func _build_campfire() -> void:
	_cyl(0.9, 0.25, Vector3(-19, 0.15, -40), Color(0.35, 0.33, 0.3))
	var flame := _cyl(0.32, 0.7, Vector3(-19, 0.6, -40), Color(1, 0.5, 0.12), true)
	flame.material = _mat_glow(Color(1, 0.5, 0.12))
	var light := OmniLight3D.new()
	light.position = Vector3(-19, 1.2, -40)
	light.light_color = Color(1, 0.6, 0.3)
	light.light_energy = 1.6
	light.omni_range = 9.0
	add_child(light)


func _build_bridge() -> void:
	_box(Vector3(3.4, 0.35, 36), Vector3(-16, 0.125, -6), WOOD, true)
	for i in 3:
		_cyl(0.16, 2.2, Vector3(-17.6, -0.2, -16.0 + i * 10.0), WOOD_DARK)
		_cyl(0.16, 2.2, Vector3(-14.4, -0.2, -16.0 + i * 10.0), WOOD_DARK)
	_box_rot(Vector3(3.4, 0.35, 4), Vector3(-16, 0.1, 13.7), Vector3(0.087, 0, 0), WOOD, true)
	_box_rot(Vector3(3.4, 0.35, 4), Vector3(-16, 0.1, -25.7), Vector3(-0.087, 0, 0), WOOD, true)


func _build_wasteland() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 9:
		var pos := Vector3(rng.randf_range(-75.0, 75.0), 0.0, rng.randf_range(28.0, 112.0))
		_dead_tree(pos, rng.randf_range(0.8, 1.3), rng.randf_range(-0.35, 0.35), rng.randf_range(-0.18, 0.18))
	_build_pier()
	_build_buildings()
	_build_hill_and_ship()
	_container(Vector3(24, 0, 15), "barrel", "Обыскать", 2)
	_container(Vector3(27, 0, 17.5), "barrel", "Обыскать", 2)
	_container(Vector3(-8, 0, 26), "crate", "Открыть", 2)
	_container(Vector3(36, 0, 20), "crate", "Открыть", 2)
	_pickup(Vector3(30, 0.45, -13), "keycard")
	_pickup(Vector3(56, 9.2, 96), "scrap")
	_pickup(Vector3(62, 9.2, 88), "scrap")
	_pickup(Vector3(-3, 0.15, 76), "scrap")
	_pickup(Vector3(-44, 0.15, 70), "scrap")
	_pickup(Vector3(-14, 0.15, 88), "bandage")


func _build_pier() -> void:
	_box(Vector3(4, 0.35, 26), Vector3(30, 0.25, -1), WOOD, true)
	for i in 4:
		_cyl(0.18, 3.0, Vector3(28.2, -1.2, 10.0 - i * 7.0), WOOD_DARK)
		_cyl(0.18, 3.0, Vector3(31.8, -1.2, 10.0 - i * 7.0), WOOD_DARK)
	_box_rot(Vector3(4, 0.35, 4), Vector3(30, 0.1, 13.7), Vector3(0.087, 0, 0), WOOD, true)


func _build_buildings() -> void:
	_panel_building(Vector3(-6, 0, 86), 16, 18, 12, 0.0, true)
	_panel_building(Vector3(-38, 0, 96), 12, 13, 10, 0.2, false)
	_panel_building(Vector3(-24, 0, 54), 9, 10, 8, -0.1, false)
	_box(Vector3(4, 2, 4), Vector3(-2, 19, 88), CONCRETE)


func _panel_building(pos: Vector3, w: float, h: float, d: float, yaw: float, windows: bool) -> void:
	var body := _box(Vector3(w, h, d), Vector3(pos.x, h * 0.5, pos.z), CONCRETE, true)
	body.rotation.y = yaw
	if not windows:
		return
	for row in 4:
		for col in 3:
			_box(Vector3(1.6, 1.1, 0.14), Vector3(pos.x - w * 0.28 + col * w * 0.28, 3.0 + row * 3.4, pos.z - d * 0.5 - 0.08), WINDOW)


func _build_hill_and_ship() -> void:
	_box(Vector3(40, 9, 32), Vector3(52, 4.5, 96), Color(0.5, 0.45, 0.35), true)
	_box_rot(Vector3(26, 1.2, 9), Vector3(21, 4.2, 96), Vector3(0, 0, 0.33), Color(0.5, 0.45, 0.35), true)
	var hull := _box(Vector3(8, 6, 28), Vector3(58, 12.2, 90), RUST, true)
	hull.rotation.y = 0.22
	hull.rotation.z = -0.05
	var superstructure := _box(Vector3(6.5, 4.5, 6.0), Vector3(56, 17.5, 82), Color(0.36, 0.34, 0.32), true)
	superstructure.rotation.y = 0.22
	var funnel := _cyl(1.1, 5, Vector3(57.5, 22, 81.5), RUST)
	funnel.rotation.z = 0.18
	_box(Vector3(6, 4.5, 9), Vector3(33, 11.25, 104), Color(0.44, 0.44, 0.42), true)
	_door(Vector3(29.9, 9.0, 104), PI * 0.5)


func _build_borders() -> void:
	_wall(Vector3(0, 4, -116), Vector3(200, 12, 2))
	_wall(Vector3(0, 4, 126), Vector3(200, 12, 2))
	_wall(Vector3(-98, 4, 5), Vector3(2, 12, 244))
	_wall(Vector3(98, 4, 5), Vector3(2, 12, 244))


func _wall(pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)


func _tree(pos: Vector3, s: float) -> void:
	var trunk := CSGCylinder3D.new()
	trunk.radius = 0.25 * s
	trunk.height = 3.0 * s
	trunk.position = pos + Vector3(0, 1.5 * s, 0)
	trunk.material = _mat(TRUNK)
	trunk.use_collision = true
	add_child(trunk)
	for i in 2:
		var cone := CSGCylinder3D.new()
		cone.cone = true
		cone.radius = (2.2 - i * 0.8) * s
		cone.height = 2.6 * s
		cone.sides = 8
		cone.position = pos + Vector3(0, (2.4 + i * 1.6) * s, 0)
		cone.material = _mat(FOLIAGE if i == 0 else FOLIAGE_LIGHT)
		add_child(cone)


func _dead_tree(pos: Vector3, s: float, yaw: float, tilt: float) -> void:
	var trunk := CSGCylinder3D.new()
	trunk.radius = 0.22 * s
	trunk.height = 4.0 * s
	trunk.position = pos + Vector3(0, 2.0 * s, 0)
	trunk.rotation = Vector3(tilt, yaw, tilt)
	trunk.material = _mat(Color(0.26, 0.2, 0.14))
	trunk.use_collision = true
	add_child(trunk)
	var branch := CSGCylinder3D.new()
	branch.cone = true
	branch.radius = 0.12 * s
	branch.height = 1.8 * s
	branch.position = pos + Vector3(0.4 * s, 2.8 * s, 0.2 * s)
	branch.rotation = Vector3(0, 0, -0.9)
	branch.material = _mat(Color(0.26, 0.2, 0.14))
	add_child(branch)


func _container(pos: Vector3, kind: String, action: String, rolls: int) -> void:
	var node: Node3D = LootContainerScene.instantiate()
	node.kind = kind
	node.action_word = action
	node.rolls = rolls
	node.position = pos
	add_child(node)


func _pickup(pos: Vector3, item_id: String) -> void:
	var node: Node3D = PickupScene.instantiate()
	node.item_id = item_id
	node.position = pos
	add_child(node)


func _door(pos: Vector3, rot_y: float) -> void:
	var node: Node3D = BunkerDoorScene.instantiate()
	node.position = pos
	node.rotation.y = rot_y
	add_child(node)


func _mat(color: Color) -> StandardMaterial3D:
	var key := color.to_html()
	if not _mats.has(key):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 1.0
		_mats[key] = mat
	return _mats[key]


func _mat_alpha(color: Color, alpha: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var tint := color
	tint.a = alpha
	mat.albedo_color = tint
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.4
	return mat


func _mat_glow(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.0
	return mat


func _box(size: Vector3, pos: Vector3, color: Color, collide: bool = false) -> CSGBox3D:
	var node := CSGBox3D.new()
	node.size = size
	node.position = pos
	node.material = _mat(color)
	node.use_collision = collide
	add_child(node)
	return node


func _box_rot(size: Vector3, pos: Vector3, rot: Vector3, color: Color, collide: bool = false) -> CSGBox3D:
	var node := _box(size, pos, color, collide)
	node.rotation = rot
	return node


func _cyl(radius: float, height: float, pos: Vector3, color: Color, cone: bool = false, collide: bool = false) -> CSGCylinder3D:
	var node := CSGCylinder3D.new()
	node.radius = radius
	node.height = height
	node.position = pos
	node.cone = cone
	node.material = _mat(color)
	node.use_collision = collide
	add_child(node)
	return node

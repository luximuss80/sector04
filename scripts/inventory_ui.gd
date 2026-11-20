extends Panel

signal closed

const PickupScene: PackedScene = preload("res://scenes/objects/item_pickup.tscn")

@onready var rows: VBoxContainer = %InvRows
@onready var empty_label: Label = %InvEmpty
@onready var selected_label: Label = %InvSelected
@onready var use_button: Button = %InvUse
@onready var drop_button: Button = %InvDrop

var _selected: String = ""


func _ready() -> void:
	%InvCloseButton.pressed.connect(func() -> void: closed.emit())
	use_button.pressed.connect(_on_use_pressed)
	drop_button.pressed.connect(_on_drop_pressed)
	Game.inventory_changed.connect(_refresh)


func refresh() -> void:
	_refresh()


func _refresh() -> void:
	for child in rows.get_children():
		child.queue_free()
	_selected = ""
	_update_selection()
	if Game.inventory.is_empty():
		empty_label.visible = true
		return
	empty_label.visible = false
	for item_id: String in Game.inventory.keys():
		var row := Button.new()
		row.text = "%s ×%d" % [Game.title(item_id), Game.inventory[item_id]]
		row.custom_minimum_size = Vector2(0, 52)
		row.add_theme_font_size_override("font_size", 18)
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.pressed.connect(_on_row_pressed.bind(item_id))
		rows.add_child(row)


func _on_row_pressed(item_id: String) -> void:
	_selected = item_id
	_update_selection()


func _update_selection() -> void:
	if _selected.is_empty() or not Game.inventory.has(_selected):
		selected_label.text = "Нажмите на предмет, чтобы выбрать его"
		return
	var suffix := "" if Game.is_usable(_selected) else " (нельзя использовать)"
	selected_label.text = "Выбрано: %s ×%d%s" % [Game.title(_selected), Game.inventory[_selected], suffix]


func _on_use_pressed() -> void:
	if _selected.is_empty():
		return
	Game.use_item(_selected)


func _on_drop_pressed() -> void:
	if _selected.is_empty() or not Game.has_item(_selected):
		return
	Game.remove_item(_selected)
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		var pickup := PickupScene.instantiate()
		pickup.item_id = _selected
		pickup.position = player.global_position - player.global_transform.basis.z.normalized() * 1.5
		get_tree().current_scene.add_child(pickup)
	_refresh()

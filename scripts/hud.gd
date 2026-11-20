extends CanvasLayer

@onready var joystick: Control = $Root/JoystickArea
@onready var look_area: Control = $Root/LookArea
@onready var interact_button: Button = $Root/InteractButton
@onready var stamina_bar: ProgressBar = $Root/StaminaBar
@onready var message_label: Label = $Root/MessageLabel
@onready var jump_button: Button = $Root/JumpButton
@onready var sprint_button: Button = $Root/SprintButton
@onready var flashlight_button: Button = $Root/FlashlightButton
@onready var backpack_button: Button = $Root/BackpackButton
@onready var journal_button: Button = $Root/JournalButton
@onready var inventory_panel: Panel = $Root/InventoryPanel
@onready var journal_panel: Panel = $Root/JournalPanel

var _player: Player
var _message_tween: Tween


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	joystick.moved.connect(_on_joystick_moved)
	look_area.look_delta.connect(_player.apply_look)
	interact_button.pressed.connect(_player.interact_current)
	_player.target_changed.connect(_on_target_changed)
	jump_button.pressed.connect(_player.request_jump)
	sprint_button.toggled.connect(_on_sprint_toggled)
	flashlight_button.pressed.connect(_on_flashlight)
	backpack_button.pressed.connect(_toggle_inventory)
	journal_button.pressed.connect(_toggle_journal)
	inventory_panel.closed.connect(_on_panel_closed.bind(inventory_panel))
	journal_panel.closed.connect(_on_panel_closed.bind(journal_panel))
	Game.message_posted.connect(_show_message)
	Game.stats_changed.connect(_on_stats_changed)
	interact_button.visible = false
	message_label.modulate.a = 0.0
	_on_stats_changed()


func _process(_delta: float) -> void:
	stamina_bar.value = Game.stamina


func _on_joystick_moved(strength: Vector2) -> void:
	_player.joystick_vector = strength


func _on_target_changed(target: Node) -> void:
	if target is Interactable:
		var prompt := target.get_prompt()
		interact_button.visible = not prompt.is_empty()
		interact_button.text = prompt.to_upper()
	else:
		interact_button.visible = false


func _on_sprint_toggled(pressed: bool) -> void:
	_player.sprint_held = pressed


func _on_flashlight() -> void:
	_player.toggle_flashlight()
	flashlight_button.modulate.a = 1.0 if _player.flashlight.visible else 0.8


func _on_stats_changed() -> void:
	stamina_bar.max_value = Game.max_stamina
	stamina_bar.value = Game.stamina


func _toggle_inventory() -> void:
	inventory_panel.visible = not inventory_panel.visible
	if inventory_panel.visible:
		inventory_panel.refresh()


func _toggle_journal() -> void:
	journal_panel.visible = not journal_panel.visible
	if journal_panel.visible:
		journal_panel.refresh()


func _on_panel_closed(panel: Control) -> void:
	panel.visible = false


func _show_message(text: String) -> void:
	message_label.text = text
	message_label.modulate.a = 1.0
	if _message_tween and _message_tween.is_valid():
		_message_tween.kill()
	_message_tween = create_tween()
	_message_tween.tween_interval(2.2)
	_message_tween.tween_property(message_label, "modulate:a", 0.0, 0.8)

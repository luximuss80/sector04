extends CanvasLayer

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var head: Node3D = player.get_node("Head")
@onready var ray: RayCast3D = player.get_node("Head/Camera3D/RayCast3D")
@onready var joystick: Control = $Joystick
@onready var interact_btn: Button = $InteractButton
@onready var message_label: Label = $MessageLabel
@onready var objective_label: Label = $ObjectiveLabel
@onready var stamina_bar: ProgressBar = $Joystick/StaminaBar

var sprint_held := false
var msg_timer := 0.0
var look_sens := 0.004

func _ready() -> void:
    joystick.moved.connect(func(v: Vector2): player.set_move_touch(v))
    joystick.released.connect(func(): player.set_move_touch(Vector2.ZERO))
    $LookArea.look_drag.connect(_on_look_drag)
    $JumpButton.pressed.connect(player.do_jump)
    $SprintButton.button_down.connect(func(): sprint_held = true)
    $SprintButton.button_up.connect(func(): sprint_held = false)
    interact_btn.pressed.connect(_on_interact)
    $BackpackButton.pressed.connect(func(): $InventoryPanel.visible = not $InventoryPanel.visible)
    $NotebookButton.pressed.connect(func(): $JournalPanel.visible = not $JournalPanel.visible)
    Game.message_posted.connect(_on_message)
    Game.quests_changed.connect(_refresh_quests)
    Game.stats_changed.connect(_refresh_stamina)
    _refresh_quests()
    _refresh_stamina()

func _on_look_drag(rel: Vector2) -> void:
    player.rotate_y(-rel.x * look_sens)
    head.rotate_x(-rel.y * look_sens)
    head.rotation.x = clampf(head.rotation.x, -1.4, 1.4)

func _on_interact() -> void:
    if not ray.is_colliding():
        return
    var target_object := ray.get_collider() as Interactable
    if target_object == null:
        return
    var prompt: String = target_object.get_prompt()
    Game.post_message(prompt)
    target_object.interact(player)

func _on_message(text: String) -> void:
    message_label.text = text
    msg_timer = 3.0

func _refresh_quests() -> void:
    var current := ""
    for id in Game.quests:
        if not Game.quests[id].done:
            current = Game.quests[id].title
            break
    objective_label.text = current

func _refresh_stamina() -> void:
    stamina_bar.value = Game.stamina

func _process(delta: float) -> void:
    msg_timer -= delta
    if msg_timer <= 0.0:
        message_label.text = ""
    if ray.is_colliding():
        var target_object := ray.get_collider() as Interactable
        if target_object:
            var prompt: String = target_object.get_prompt()
            interact_btn.text = prompt
            interact_btn.visible = prompt != ""
        else:
            interact_btn.visible = false
    else:
        interact_btn.visible = false

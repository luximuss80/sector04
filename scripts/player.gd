extends CharacterBody3D

const SPEED := 4.0
const SPRINT_SPEED := 7.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENS := 0.003
const STAMINA_DRAIN := 25.0
const STAMINA_REGEN := 15.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var move_touch := Vector2.ZERO

@onready var head: Node3D = $Head
@onready var ray: RayCast3D = $Head/Camera3D/RayCast3D

func _ready() -> void:
    add_to_group("player")

func set_move_touch(v: Vector2) -> void:
    move_touch = v

func do_jump() -> void:
    if is_on_floor():
        velocity.y = JUMP_VELOCITY

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        rotate_y(-event.relative.x * MOUSE_SENS)
        head.rotate_x(-event.relative.y * MOUSE_SENS)
        head.rotation.x = clampf(head.rotation.x, -1.4, 1.4)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    var input_vec := move_touch
    var kb := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if kb != Vector2.ZERO:
        input_vec = kb

    var moving := input_vec.length() > 0.8
    if moving and Game.stamina > 0.0:
        Game.set_stamina(Game.stamina - STAMINA_DRAIN * delta)
    else:
        Game.set_stamina(Game.stamina + STAMINA_REGEN * delta)

    var speed := SPRINT_SPEED if (moving and Game.stamina > 0.0) else SPEED
    var dir := (transform.basis * Vector3(input_vec.x, 0.0, input_vec.y)).normalized()
    if dir != Vector3.ZERO:
        velocity.x = dir.x * speed
        velocity.z = dir.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, SPEED)
        velocity.z = move_toward(velocity.z, 0.0, SPEED)

    move_and_slide()

func try_interact() -> void:
    if not ray.is_colliding():
        return
    var target_object := ray.get_collider() as Interactable
    if target_object == null:
        return
    var prompt: String = target_object.get_prompt()
    Game.post_message(prompt)
    target_object.interact(self)

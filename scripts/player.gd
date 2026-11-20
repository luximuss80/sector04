class_name Player
extends CharacterBody3D

signal target_changed(target: Node)

@export var walk_speed: float = 3.4
@export var sprint_speed: float = 6.0
@export var jump_velocity: float = 4.6
@export var gravity: float = 12.0
@export var touch_sensitivity: float = 0.0035
@export var mouse_sensitivity: float = 0.0025
@export var stamina_drain_per_sec: float = 20.0
@export var stamina_regen_per_sec: float = 12.0

@onready var head: Camera3D = $Head
@onready var ray: RayCast3D = $Head/RayCast
@onready var flashlight: SpotLight3D = $Head/Flashlight

var joystick_vector: Vector2 = Vector2.ZERO
var sprint_held: bool = false

var _current_target: Node = null
var _jump_requested: bool = false


func _ready() -> void:
	Game.stats_changed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact_current()
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x - event.relative.y * mouse_sensitivity, -1.4, 1.4)


func apply_look(delta_pixels: Vector2) -> void:
	rotate_y(-delta_pixels.x * touch_sensitivity)
	head.rotation.x = clampf(head.rotation.x - delta_pixels.y * touch_sensitivity, -1.4, 1.4)


func toggle_flashlight() -> void:
	flashlight.visible = not flashlight.visible


func request_jump() -> void:
	_jump_requested = true


func interact_current() -> void:
	if _current_target is Interactable:
		_current_target.interact(self)
		target_changed.emit(_current_target)


func _physics_process(delta: float) -> void:
	_move(delta)
	_update_target()


func _move(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back") + joystick_vector
	if input_2d.length() > 1.0:
		input_2d = input_2d.normalized()
	var direction := global_transform.basis * Vector3(input_2d.x, 0.0, input_2d.y)
	direction.y = 0.0
	var moving: bool = direction.length() > 0.05
	var sprinting: bool = (sprint_held or Input.is_action_pressed("sprint")) and moving and Game.stamina > 1.0
	if sprinting:
		Game.stamina = maxf(Game.stamina - stamina_drain_per_sec * delta, 0.0)
		Game.stats_changed.emit()
	elif Game.stamina < Game.max_stamina:
		Game.stamina = minf(Game.stamina + stamina_regen_per_sec * delta, Game.max_stamina)
		Game.stats_changed.emit()
	var speed := sprint_speed if sprinting else walk_speed
	if moving:
		var normalized_dir := direction.normalized()
		velocity.x = normalized_dir.x * speed
		velocity.z = normalized_dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, walk_speed * 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, walk_speed * 8.0 * delta)
	if Input.is_action_just_pressed("jump") or _jump_requested:
		_jump_requested = false
		if is_on_floor():
			velocity.y = jump_velocity
	move_and_slide()


func _update_target() -> void:
	var collider: Object = ray.get_collider() if ray.is_colliding() else null
	if collider != _current_target:
		_current_target = collider
		target_changed.emit(_current_target)

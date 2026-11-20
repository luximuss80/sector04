extends Control

signal moved(strength: Vector2)

const RADIUS: float = 92.0

@onready var base: Control = $Base
@onready var knob: Control = $Knob

var _touch_index: int = -1
var _center: Vector2 = Vector2.ZERO


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_center = event.position
			base.position = event.position - base.size * 0.5
			base.visible = true
			knob.position = event.position - knob.size * 0.5
			moved.emit(Vector2.ZERO)
			accept_event()
		elif not event.pressed and event.index == _touch_index:
			_release()
			accept_event()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		var offset: Vector2 = (event.position - _center).limit_length(RADIUS)
		knob.position = _center + offset - knob.size * 0.5
		moved.emit(offset / RADIUS)
		accept_event()


func _release() -> void:
	_touch_index = -1
	base.visible = false
	moved.emit(Vector2.ZERO)

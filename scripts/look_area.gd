extends Control

signal look_delta(delta: Vector2)

var _touch_index: int = -1


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			accept_event()
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			accept_event()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		look_delta.emit(event.relative)
		accept_event()

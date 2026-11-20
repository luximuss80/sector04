extends Control

signal look_drag(rel: Vector2)

var touch_index := -1
var last := Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and touch_index == -1:
            touch_index = event.index
            last = event.position
        elif not event.pressed and event.index == touch_index:
            touch_index = -1
    elif event is InputEventScreenDrag and event.index == touch_index:
        look_drag.emit(event.position - last)
        last = event.position

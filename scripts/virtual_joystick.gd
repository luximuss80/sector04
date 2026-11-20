extends Control

signal moved(vec: Vector2)
signal released

@onready var knob: Control = $Knob

var touch_index := -1
var center := Vector2.ZERO
const RADIUS := 90.0

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and touch_index == -1:
            touch_index = event.index
            center = event.position
            _update_knob(event.position)
        elif not event.pressed and event.index == touch_index:
            touch_index = -1
            knob.position = Vector2(90, 90)
            moved.emit(Vector2.ZERO)
            released.emit()
    elif event is InputEventScreenDrag and event.index == touch_index:
        _update_knob(event.position)

func _update_knob(pos: Vector2) -> void:
    var v := (pos - center).limit_length(RADIUS)
    knob.position = center + v - knob.size * 0.5
    moved.emit(v / RADIUS)

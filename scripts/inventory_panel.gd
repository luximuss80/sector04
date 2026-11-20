extends Panel

@onready var items: ItemList = $Items

func _ready() -> void:
    $UseButton.pressed.connect(_on_use)
    $DropButton.pressed.connect(_on_drop)
    Game.inventory_changed.connect(_refresh)
    _refresh()

func _refresh() -> void:
    items.clear()
    for it in Game.inventory:
        items.add_item(it)

func _selected_id() -> String:
    var sel := items.get_selected_items()
    if sel.size() == 0:
        return ""
    return items.get_item_text(sel[0])

func _on_use() -> void:
    var id := _selected_id()
    if id == "":
        return
    Game.post_message("Used: " + id)
    Game.remove_item(id)

func _on_drop() -> void:
    var id := _selected_id()
    if id == "":
        return
    Game.post_message("Dropped: " + id)
    Game.remove_item(id)

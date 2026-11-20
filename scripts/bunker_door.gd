extends Interactable

@export var required_item: String = "key"
var opened := false

func get_prompt() -> String:
    if opened:
        return ""
    if Game.has_item(required_item):
        return "Open"
    return "Locked. Need key"

func interact(player: Node) -> void:
    if opened:
        return
    if Game.has_item(required_item):
        opened = true
        Game.remove_item(required_item)
        Game.complete_quest("open_bunker")
        Game.bunker_opened.emit()
        var tw := create_tween()
        tw.tween_property(self, "position:y", position.y + 3.2, 2.0)
    else:
        Game.post_message("The door is locked.")

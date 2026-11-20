extends Interactable

@export var item_id: String = "scrap"

func get_prompt() -> String:
    return "Take: " + item_id

func interact(player: Node) -> void:
    Game.add_item(item_id)
    if item_id == "key":
        Game.complete_quest("find_key")
    queue_free()

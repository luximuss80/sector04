extends Node

signal message_posted(text: String)
signal stats_changed
signal inventory_changed
signal quests_changed
signal bunker_opened

var stamina := 100.0
var inventory: Array[String] = []
var quests := {}

func _ready() -> void:
    add_quest("find_key", "Find the bunker key")
    add_quest("open_bunker", "Open the bunker door")

func set_stamina(v: float) -> void:
    stamina = clampf(v, 0.0, 100.0)
    stats_changed.emit()

func add_item(id: String) -> void:
    inventory.append(id)
    inventory_changed.emit()
    post_message("Received: " + id)

func has_item(id: String) -> bool:
    return inventory.has(id)

func remove_item(id: String) -> void:
    inventory.erase(id)
    inventory_changed.emit()

func add_quest(id: String, title: String) -> void:
    if not quests.has(id):
        quests[id] = {"title": title, "done": false}
        quests_changed.emit()

func complete_quest(id: String) -> void:
    if quests.has(id) and not quests[id].done:
        quests[id].done = true
        quests_changed.emit()
        post_message("Quest complete: " + quests[id].title)

func post_message(text: String) -> void:
    message_posted.emit(text)

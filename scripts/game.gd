extends Node

signal inventory_changed
signal stats_changed
signal quest_updated
signal message_posted(text: String)

const ITEMS: Dictionary = {
	"canned_food": {"title": "Консервы", "usable": true},
	"water": {"title": "Фляга воды", "usable": true},
	"bandage": {"title": "Бинт", "usable": true},
	"scrap": {"title": "Металлолом", "usable": false},
	"keycard": {"title": "Ключ-карта", "usable": false},
}

var inventory: Dictionary = {}
var health: float = 100.0
var max_health: float = 100.0
var stamina: float = 100.0
var max_stamina: float = 100.0

var quests: Array[Dictionary] = [
	{"id": "scrap", "title": "Собрать 3 металлолома", "progress": 0, "target": 3, "done": false},
	{"id": "keycard", "title": "Найти ключ-карту от бункера", "progress": 0, "target": 1, "done": false},
	{"id": "bunker", "title": "Открыть дверь бункера", "progress": 0, "target": 1, "done": false, "locked": true},
]


func title(item_id: String) -> String:
	return ITEMS[item_id]["title"] if ITEMS.has(item_id) else item_id


func is_usable(item_id: String) -> bool:
	return ITEMS[item_id]["usable"] if ITEMS.has(item_id) else false


func add_item(item_id: String, amount: int = 1) -> void:
	inventory[item_id] = int(inventory.get(item_id, 0)) + amount
	inventory_changed.emit()
	post_message("Получено: %s ×%d" % [title(item_id), amount])
	if item_id == "scrap":
		advance_quest("scrap", amount)
	elif item_id == "keycard":
		complete_quest("keycard")
		unlock_quest("bunker")


func remove_item(item_id: String, amount: int = 1) -> void:
	if not inventory.has(item_id):
		return
	inventory[item_id] = int(inventory[item_id]) - amount
	if int(inventory[item_id]) <= 0:
		inventory.erase(item_id)
	inventory_changed.emit()


func has_item(item_id: String) -> bool:
	return int(inventory.get(item_id, 0)) > 0


func use_item(item_id: String) -> bool:
	if not is_usable(item_id) or not has_item(item_id):
		return false
	match item_id:
		"canned_food":
			health = minf(health + 25.0, max_health)
		"water":
			stamina = max_stamina
		"bandage":
			health = minf(health + 40.0, max_health)
	remove_item(item_id)
	stats_changed.emit()
	post_message("Использовано: %s" % title(item_id))
	return true


func find_quest(quest_id: String) -> Dictionary:
	for quest in quests:
		if quest["id"] == quest_id:
			return quest
	return {}


func complete_quest(quest_id: String) -> void:
	var quest := find_quest(quest_id)
	if quest.is_empty() or bool(quest["done"]):
		return
	quest["done"] = true
	quest_updated.emit()


func unlock_quest(quest_id: String) -> void:
	var quest := find_quest(quest_id)
	if quest.is_empty() or not bool(quest.get("locked", false)):
		return
	quest["locked"] = false
	quest_updated.emit()


func advance_quest(quest_id: String, amount: int) -> void:
	var quest := find_quest(quest_id)
	if quest.is_empty() or bool(quest["done"]):
		return
	quest["progress"] = int(quest["progress"]) + amount
	if int(quest["progress"]) >= int(quest["target"]):
		quest["done"] = true
		post_message("Задание выполнено: %s" % quest["title"])
	quest_updated.emit()


func post_message(text: String) -> void:
	message_posted.emit(text)

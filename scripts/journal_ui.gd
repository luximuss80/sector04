extends Panel

signal closed

@onready var rows: VBoxContainer = %QuestRows


func _ready() -> void:
	%JournalCloseButton.pressed.connect(func() -> void: closed.emit())
	Game.quest_updated.connect(_on_quest_updated)


func refresh() -> void:
	for child in rows.get_children():
		child.queue_free()
	for quest: Dictionary in Game.quests:
		if bool(quest.get("locked", false)):
			continue
		var label := Label.new()
		var mark := "[x] " if bool(quest["done"]) else "[  ] "
		var progress := ""
		if int(quest["target"]) > 1 and not bool(quest["done"]):
			progress = " (%d/%d)" % [int(quest["progress"]), int(quest["target"])]
		label.text = mark + str(quest["title"]) + progress
		label.add_theme_font_size_override("font_size", 18)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rows.add_child(label)


func _on_quest_updated() -> void:
	if visible:
		refresh()

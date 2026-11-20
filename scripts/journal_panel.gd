extends Panel

@onready var quest_list: Label = $QuestList

func _ready() -> void:
    Game.quests_changed.connect(_refresh)
    _refresh()

func _refresh() -> void:
    var lines: Array[String] = []
    for id in Game.quests:
        var q: Dictionary = Game.quests[id]
        lines.append(("[x] " if q.done else "[ ] ") + q.title)
    quest_list.text = "\n".join(lines)

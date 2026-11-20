class_name Interactable
extends StaticBody3D

@export var prompt_text: String = "Interact"

func get_prompt() -> String:
    return prompt_text

func interact(player: Node) -> void:
    pass

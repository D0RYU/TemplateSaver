@tool
extends LineEdit

@export var add_container: VBoxContainer
@export var search: TextureButton

func ResetCaret() -> void:
	set_caret_column(text.length())

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ENTER and has_focus():
		ResetCaret.call_deferred()

func TextChanged(_new_text: String) -> void:
	search.disabled = text == ""
	
	for child in add_container.get_children():
		child.visible = text in child.name and child is MarginContainer or child is HSeparator or text.strip_edges() == ""

func DeleteAll() -> void:
	search.disabled = true
	text = ""

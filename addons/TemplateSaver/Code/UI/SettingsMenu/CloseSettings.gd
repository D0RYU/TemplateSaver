@tool
extends TextureButton

func OnPressed() -> void:
	get_node("../..").queue_free()

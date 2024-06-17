@tool
extends TextureButton

func OnPressed() -> void:
	get_owner().queue_free()

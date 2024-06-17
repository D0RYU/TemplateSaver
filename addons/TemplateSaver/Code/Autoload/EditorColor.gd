@tool
class_name EditorColor extends Node

static var editor_settings: EditorSettings = EditorInterface.get_editor_settings()
static var base_color: Color:
	get:
		return editor_settings.get("interface/theme/base_color")
static var accent_color: Color:
	get:
		return editor_settings.get("interface/theme/accent_color")

static func GetHint(color: Color, amount: float, alpha: float = 1.0) -> Color:
	return Color(color.r * amount, color.g * amount, color.b * amount, alpha)

static func GetAlpha(color: Color, alpha: float = 1.0) -> Color:
	return Color(color.r, color.g, color.b, alpha)

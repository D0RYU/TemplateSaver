@tool
extends Control

@export var top: PanelContainer
@export var bottom: PanelContainer
@export var tab_container: TabContainer
@export var built_in_container: VBoxContainer
@export var add_on_container: VBoxContainer

@onready var editor_settings: EditorSettings = EditorInterface.get_editor_settings()

func _ready() -> void:
	editor_settings.settings_changed.connect(SetColor)
	add_on_container.child_entered_tree.connect(ChangeAddOnColor)
	SetColor()

func SetColor() -> void:
	var tab_selected: StyleBoxFlat = tab_container.get("theme_override_styles/tab_selected")
	var tab_hovered: StyleBoxFlat = tab_container.get("theme_override_styles/tab_hovered")
	var tab_unselected: StyleBoxFlat = tab_container.get("theme_override_styles/tab_unselected")
	
	top.get("theme_override_styles/panel").bg_color = EditorColor.base_color
	bottom.get("theme_override_styles/panel").bg_color = EditorColor.GetHint(EditorColor.base_color, 0.7)
	tab_selected.bg_color = EditorColor.base_color
	tab_selected.border_color = EditorColor.accent_color
	tab_hovered.bg_color = EditorColor.GetHint(EditorColor.base_color, 1.25)
	tab_hovered.border_color = EditorColor.accent_color
	tab_unselected.bg_color = EditorColor.GetHint(EditorColor.base_color,  0.6)
	
	for built_in in built_in_container.get_children():
		ChangeBuiltInColor(built_in)
	
	for add_on in add_on_container.get_children():
		ChangeAddOnColor(add_on)

func ChangeBuiltInColor(scene) -> void:
	if scene is MarginContainer:
		var panel_style: StyleBoxFlat = scene.get_node("Panel").get("theme_override_styles/panel")
		
		panel_style.bg_color = EditorColor.GetHint(EditorColor.accent_color, 0.6, 0.3)
		panel_style.border_color = EditorColor.GetHint(EditorColor.accent_color, 1, 0)

func ChangeAddOnColor(scene) -> void:
	if scene is MarginContainer:
		var container: VBoxContainer = scene.get_node("Container")
		var panel_style: StyleBoxFlat = container.get_node("Panel").get("theme_override_styles/panel")
		var rename: LineEdit = container.get_node("Panel/Info/Label/MarginContainer/Rename")
		
		panel_style.bg_color = EditorColor.GetHint(EditorColor.accent_color, 0.6, 0.3)
		panel_style.border_color = EditorColor.GetHint(EditorColor.accent_color, 1, 0)
		container.get_child(1).get("theme_override_styles/separator").color = EditorColor.GetHint(EditorColor.accent_color, 1, 0)
		rename.get("theme_override_styles/normal").bg_color = EditorColor.GetHint(EditorColor.base_color, 0.75)

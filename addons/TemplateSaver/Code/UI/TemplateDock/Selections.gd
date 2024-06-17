@tool
extends VBoxContainer

@export var add_button: TextureButton
@export var bottom: PanelContainer
@export var settings: TextureButton

var drag_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/SceneDrag.tscn")
var file_manager_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/FileManager.tscn")

var last_selected: Array = []
var hovered_scene: MarginContainer
var drag_distance: float = 0
var is_dragging: bool = false
var dragger: VBoxContainer
var current_rename: LineEdit
var last_draw: bool = false
var template_data: Object:
	get:
		while !get_tree().root.has_node("TemplateData"):
			await get_tree().create_timer(0).timeout
		
		return get_tree().root.get_node("TemplateData")

func _ready() -> void:
	child_entered_tree.connect(AddScene)
	
	for child in get_children():
		AddScene(child)

func _process(delta: float) -> void:
	if is_dragging:
		if drag_distance >= 10 and !is_instance_valid(dragger) and !is_instance_valid(current_rename):
			StartDrag()
		
		if is_instance_valid(dragger):
			dragger.position = lerp(dragger.position, get_viewport().get_mouse_position(), 0.8)

func AddScene(Scene: Control) -> void:
	if Scene is MarginContainer and !Scene.mouse_entered.is_connected(MouseEnteredScene.bind(Scene)):
		Scene.mouse_entered.connect(MouseEnteredScene.bind(Scene))
		Scene.rename.mouse_entered.connect(MouseEnteredScene.bind(Scene))
		Scene.mouse_exited.connect(MouseExitedScene)
		Scene.rename.mouse_exited.connect(MouseExitedScene)

func FileSelected(path: String, scene: MarginContainer) -> void:
	if path.get_extension() == "tscn":
		if template_data.MakeDirectory(path.left(-5)):
			var template: Array = template_data.data[scene.scene_label.text].scene
			
			for dependency in template:
				ResourceSaver.save(dependency[1], path.left(-5) + "/" + dependency[0] + ".tscn")
	else:
		Dialog.NewAlert("invalid save, tscn expected")

func StartDrag():
	var new_dragger := VBoxContainer.new()
	var selected: Array = last_selected.duplicate()
	
	dragger = new_dragger
	selected.sort_custom(func(a, b) -> bool: return a.get_index() < b.get_index())
	EditorInterface.get_base_control().add_child.call_deferred(dragger)
	
	for child in selected:
		var new_drag: HBoxContainer = drag_scene.instantiate()
		
		new_drag.get_node("Label").text = child.scene_label.text
		new_drag.global_position = get_viewport().get_mouse_position()
		dragger.add_child(new_drag)
		child.rename.release_focus()
		child.rename.visible = false
		CheckRenameFocus()
	
	add_button.StartDrag(selected)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !last_selected.is_empty():
		drag_distance += event.relative.length()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if IsOverBottom():
			if event.pressed:
				if last_selected.is_empty():
					Dialog.NewContext(get_viewport().get_mouse_position(), [
						{text = "Open Settings", call = settings.OnPressed}
					])
				else:
					Dialog.NewContext(get_viewport().get_mouse_position(), [
						{text = "Delete Template(s)", accel = KEY_MASK_CMD_OR_CTRL | KEY_X, call = (func() -> void:
							var confirmation: ConfirmationDialog = Dialog.NewConfirm("are you sure you want to remove all selections?")
							var selected: Array = last_selected.duplicate()
							
							confirmation.confirmed.connect(func() -> void:
								var templates: Array = []
								
								for child in selected:
									templates.append(child.scene_label.text)
								
								if !await template_data.Remove(templates):
									Dialog.NewAlert("template remove failed")
									return
							)
							
							last_selected.clear())
						}
					])
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
		is_dragging = false
		
		if is_instance_valid(dragger):
			add_button.StopDrag()
			dragger.queue_free()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if is_instance_valid(hovered_scene) or is_instance_valid(hovered_scene) and hovered_scene.mouse_over_rename:
			var rename: LineEdit = hovered_scene.rename
			
			if !event.pressed:
				if !last_selected.is_empty():
					if !hovered_scene.mouse_over_rename and rename.visible:
						pass
					elif last_draw and !event.is_command_or_control_pressed() and \
					(last_selected.back() == hovered_scene and event.shift_pressed or !event.shift_pressed):
						hovered_scene.ResetCaret.call_deferred()
						rename.text = hovered_scene.scene_label.text
						rename.visible = true
						rename.grab_focus()
						current_rename = rename
						DeselectAll(func(child): return child != hovered_scene)
					
					if last_selected.size() >= 2:
						if !event.is_command_or_control_pressed():
							SelectScene(hovered_scene, event)
							
							if !event.shift_pressed:
								DeselectAll(func(child): return child != hovered_scene)
					
					return
			else:
				if !event.double_click:
					drag_distance = 0
					is_dragging = true
				
				if event.double_click and !event.is_command_or_control_pressed() and !is_instance_valid(current_rename):
					var file_manager: FileDialog = file_manager_scene.instantiate()
					file_manager.file_mode = FileDialog.FILE_MODE_SAVE_FILE
					file_manager.file_selected.connect(FileSelected.bind(hovered_scene))
					
					EditorInterface.get_base_control().add_child.call_deferred(file_manager)
				
				if last_selected.size() <= 1:
					if !event.shift_pressed and !event.is_command_or_control_pressed():
						DeselectAll(func(child): return child != hovered_scene)
					
					if is_instance_valid(current_rename):
						DeselectAll()
					
					SelectScene(hovered_scene, event)
				elif event.is_command_or_control_pressed():
					SelectScene(hovered_scene, event)
		elif !event.shift_pressed and !event.is_command_or_control_pressed() and event.pressed:
			DeselectAll()

func MouseEnteredScene(scene: MarginContainer) -> void:
	hovered_scene = scene

func MouseExitedScene() -> void:
	hovered_scene = null

func CheckRenameFocus() -> void:
	if is_instance_valid(current_rename) and !current_rename.has_focus():
		current_rename = null

func IsOverBottom() -> bool:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var size_and_position: Vector2 = bottom.global_position + bottom.size
	
	return mouse_position.x > bottom.global_position.x and mouse_position.y > bottom.global_position.y and mouse_position.x < size_and_position.x and mouse_position.y < size_and_position.y

func GetAlpha(color: Color, alpha: float = 1.0) -> Color:
	return Color(color.r, color.g, color.b, alpha)

func GetInBetween(Scene: MarginContainer) -> Array:
	var last_index: int = Scene.get_index() if last_selected.is_empty() else last_selected.back().get_index()
	var start_index: int = min(Scene.get_index(), last_index)
	var end_index: int = max(Scene.get_index(), last_index)
	var offset := int(Scene.get_index() < last_index)
	
	return get_children().slice(start_index + offset, end_index)

func DeselectAll(extra: Callable = (func(child): return true)) -> void:
	for child in get_children():
		if child is MarginContainer and extra.call(child):
			child.rename.visible = false
			child.panel_style.draw_center = false
			child.panel_style.border_color = GetAlpha(EditorColor.accent_color, 0)
			last_selected.erase(child)
			CheckRenameFocus()

func SelectScene(Scene: MarginContainer, event: InputEvent) -> void:
	var selected: bool = true
	
	if event.is_command_or_control_pressed() and selected and Scene.panel_style.draw_center:
		selected = !selected
	
	if event.shift_pressed:
		for child in GetInBetween(Scene):
			if child is MarginContainer:
				if last_selected.find(child) == -1:
					last_selected.append(child)
				
				child.panel_style.draw_center = true
				child.panel_style.border_color = GetAlpha(EditorColor.accent_color, 1)
	
	if selected and last_selected.find(Scene) == -1:
		last_selected.append(Scene)
	elif !selected:
		last_selected.erase(Scene)
	
	last_draw = Scene.panel_style.draw_center
	Scene.panel_style.draw_center = selected
	Scene.panel_style.border_color = GetAlpha(EditorColor.accent_color, int(selected))

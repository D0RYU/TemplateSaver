@tool
extends Node

var DataPath = ""
var Data: Dictionary = {}

func Add(Name: String, ID: String, Template: PackedScene, UI: HBoxContainer) -> bool:
	if !Data.has(Name):
		Data[Name] = {
			ID = ID,
			Scene = Template.duplicate(),
			UI = UI
		}
		
		return true
	
	return false

func Remove(Name: String) -> bool:
	if Data.has(Name) and get_tree().root.has_node("TemplateData"):
		var TreeTemplateData: Object = get_tree().root.get_node("TemplateData")
		var Directory: DirAccess = DirAccess.open(TreeTemplateData.DataPath)
		
		Directory.remove(Data[Name].ID + ".dat")
		Data[Name].UI.queue_free()
		Data[Name] = null
		
		return true
	
	return false

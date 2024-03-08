@tool
extends Node

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
	if Data.has(Name):
		var Directory: DirAccess = DirAccess.open("C:/Godot/")
		
		Directory.remove(Data[Name].ID + ".dat")
		Data[Name].UI.queue_free()
		Data[Name] = null
		
		return true
	
	return false

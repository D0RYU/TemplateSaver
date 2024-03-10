@tool
extends VBoxContainer

@onready var DataPath = get_node("DataPath")

func _ready():
	if get_tree().root.has_node("TemplateData"):
		var TreeTemplateData: Object = get_tree().root.get_node("TemplateData")
		
		DataPath.text = "DataPath: " + TreeTemplateData.DataPath

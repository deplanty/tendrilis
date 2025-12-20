@tool
extends Node2D


@export_tool_button("Export characters") var tb_export = _on_tb_export_pressed


func _on_tb_export_pressed() -> void:
	var characters: Array[Dictionary] = []
	for child in $Letters.get_children():
		var letter = child.as_dict()
		characters.push_back(letter)
	for child in $Specials.get_children():
		var letter = child.as_dict()
		characters.push_back(letter)
	var fid = FileAccess.open("res://editor/characters.json", FileAccess.WRITE)
	fid.store_string(JSON.stringify(characters, "", false))
	fid.close()
	print("Characters exported!")

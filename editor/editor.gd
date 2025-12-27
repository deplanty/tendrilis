@tool
extends Node2D


@export_tool_button("Export characters") var tb_export = _on_tb_export_pressed

@export var grid_size: float = 80:
	set(value):
		grid_size = value
		queue_redraw()

@export var grid_padding: int = 10:
	set(value):
		grid_padding = value
		queue_redraw()


func _draw() -> void:
	var grid = 5
	for row in grid:
		for column in grid:
			draw_rect(
				Rect2(Vector2(column * (grid_size + grid_padding), row * (grid_size + grid_padding)), Vector2(grid_size, grid_size)),
				Color.GRAY,
				false,
				1
			)


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

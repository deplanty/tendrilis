@tool
extends Sprite2D


## Redraw the curve
@export_tool_button("Connect", "Reload") var tb_connect = _on_tb_connect_pressed

## Reposition the position and the points of the Path2D curves
@export_tool_button("Reposition", "Reload") var tb_reposition = _on_tb_reposition_pressed

## Reposition the position and the points of the Path2D curves
@export_tool_button("Flip H", "Reload") var tb_flip_h = _on_tb_flip_h_pressed

@export var letter: String = "":
	set(value):
		letter = value
		name = "EditorLetter" + letter_text.to_pascal_case()

@export var size: float = 0:
	set(value):
		size = value
		queue_redraw()

@export_range(2, 200, 1, "or_greater") var subdivision: int = 50:
	set(value):
		subdivision = value
		queue_redraw()


var letter_text: String:
	get():
		return {
			" ": "space",
			".": "dot",
			",": "comma",
			"+": "plus",
			"-": "minus",
		}.get(letter, letter)

#region Magics

func _draw() -> void:
	draw_line(Vector2(0, 0), Vector2(size, 0), Color.FIREBRICK, 2, true)
	
	for child in get_children():
		if child is not Path2D:
			continue
		var points = PackedVector2Array()
		var curve_len = child.curve.get_baked_length()
		points.push_back(child.curve.get_point_position(0))
		for index in subdivision:
			points.push_back(
				child.curve.sample_baked(curve_len * (1.0 + index) / subdivision)
			)
		draw_polyline(points, Color.WHITE, 2, true)

#endregion
#region Events tool buttons

func _on_tb_connect_pressed() -> void:
	for child in get_children():
		child.curve.changed.connect(queue_redraw)
	queue_redraw()


func _on_tb_reposition_pressed() -> void:
	for path2d in get_children():
		var curve: Curve2D = path2d.curve
		# Move the points
		for index in path2d.curve.point_count:
			curve.set_point_position(index, curve.get_point_position(index) + path2d.position)
		# Reset the Path2D to (0, 0)
		path2d.position = Vector2(0, 0)
	queue_redraw()


func _on_tb_flip_h_pressed() -> void:
	for path2d in get_children():
		var curve: Curve2D = path2d.curve
		# Move the points
		var point: Vector2
		for index in path2d.curve.point_count:
			point = curve.get_point_position(index)
			point.y *= -1
			curve.set_point_position(index, point)
			
			point = curve.get_point_in(index)
			point.y *= -1
			curve.set_point_in(index, point)
			
			point = curve.get_point_out(index)
			point.y *= -1
			curve.set_point_out(index, point)
		# Reset the Path2D to (0, 0)
		path2d.position = Vector2(0, 0)
	queue_redraw()

#endregion
#region Private Methods

func _get_shapes() -> Array:
	var shapes: Array[Array] = []
	for child in get_children():
		if child is not Path2D:
			continue
		var points: Array[Dictionary] = []
		for index in child.curve.point_count:
			points.append({
				"position": _vec2_as_point(child.curve.get_point_position(index)),
				"in": _vec2_as_point(child.curve.get_point_in(index)),
				"out": _vec2_as_point(child.curve.get_point_out(index)),
			})
		shapes.append(points)
	return shapes


func _vec2_as_point(vec2: Vector2) -> Array:
	return [vec2.x, vec2.y]

#endregion
#region Public methods

## Return the instruction to draw the character to be stored as a dictionary.
func as_dict() -> Dictionary:
	return {
		"name": letter_text,
		"symbol": letter,
		"base_size": size,
		"base_subdivision": subdivision,
		"shapes": _get_shapes()
	}

@tool
class_name TendrilisCharacter
extends Node2D


## The letter to display.
@export var letter: String = "":
	set(value):
		letter = value
		if not is_node_ready():
			await ready
		_draw_shapes()
		$Label.text = letter

## The fontsize of the letter.
@export_range(1, 100, 1, "or_greater", "suffix:pt") var fontsize: int = 32:
	set(value):
		fontsize = value
		if not is_node_ready():
			await ready
		_update_shapes()

## The color of the letter.
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		if not is_node_ready():
			await ready
		_update_shapes()

## Show the latin letter below the tendrilis letter.
@export var show_translation: bool = false:
	set(value):
		show_translation = value
		if not is_node_ready():
			await ready
		$Label.visible = value

## Show a factor of the shape.
@export_range(0, 1, 0.01) var show_factor: float = 1.0:
	set(value):
		_show_factor_previous = show_factor
		show_factor = value
		if not is_node_ready():
			await ready
		_draw_update_shapes()

@onready var shapes_container: Node2D = %Shapes


var _show_factor_previous: float = show_factor
var _data: TendrilisData.Character
var _pt_to_px: float = 4.0 / 3

#region Magics

func _ready() -> void:
	_draw_shapes()

#endregion
#region Private methods

func _draw_shapes() -> void:
	if letter == "":
		return

	_data = TendrilisData.get_character(letter)

	var subdivision = _data.base_subdivision
	# Create all the lines of the letter
	for shapes in _data.shapes:
		var curve = Curve2D.new()
		for point in shapes:
			curve.add_point(point["position"], point["in"], point["out"])

		var line: Line2D = Line2D.new()
		line.width = 2
		line.default_color = color
		line.antialiased = true
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		var curve_len = curve.get_baked_length()
		for index in subdivision:
			line.add_point(
				curve.sample_baked(curve_len * index / subdivision)
			)
		# If the curve loops (starting point == ending point)
		# Then the line should be closed
		# Else the line continues to the ending point
		var last = curve.point_count - 1
		if curve.get_point_position(0).is_equal_approx(curve.get_point_position(last)):
			line.closed = true
		else:
			line.add_point(
				curve.get_point_position(last)
			)
		shapes_container.add_child(line)
	_update_shapes()


func _draw_update_shapes() -> void:
	pass

## Update the shapes of the character
func _update_shapes() -> void:
	if letter == "":
		return

	var line_scale = (_pt_to_px * fontsize) / _data.base_size
	# Create all the lines of the letter
	for line in shapes_container.get_children():
		line.default_color = color
		# FIXME: scale the node to match the font size. Not good (?) because the thickness is scaled too.
		# Scale the letter to match the fontsize
		line.scale.x = line_scale
		line.scale.y = line_scale

	$Label.position.y = fontsize

#endregion

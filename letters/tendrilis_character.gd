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
@export_range(0, 1, 0.001) var show_factor: float = 0:
	set(value):
		show_factor = value
		if not is_node_ready():
			await ready
		for line in shapes_container.get_children():
			line.show_factor = show_factor
		#$Label.scale = Vector2(show_factor, show_factor)

@onready var shapes_container: Node2D = %Shapes


var _data: TendrilisData.Character
var _pt_to_px: float = 4.0 / 3

#region Magics

func _ready() -> void:
	_draw_shapes()

#endregion
#region Private methods

func _draw_shapes() -> void:
	# Remove all the children before drawing the character
	for child in shapes_container.get_children():
		child.queue_free()

	# Do nothing if the character is empty
	if letter == "":
		return

	# Get the character data to draw it
	_data = TendrilisData.get_character(letter)

	# Create all the lines of the character
	for shape in _data.shapes:
		var curve = Curve2D.new()
		for point in shape:
			curve.add_point(point["position"], point["in"], point["out"])

		var line: GrowingLine2D = GrowingLine2D.new()
		line.width = 2
		line.default_color = color
		line.antialiased = true
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.cached_points = curve.get_baked_points()
		shapes_container.add_child(line)
	_update_shapes()

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

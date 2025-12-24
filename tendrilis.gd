@tool
class_name Tendrilis
extends Path2D

#region Script variables - Export

@export_tool_button("Grow vine", "GuiVisibilityVisible") var tb_grow_vine = _on_tb_grow_vine_pressed

## The text to translate to tendrilis.
@export_multiline var text: String = "":
	set(value):
		text = value
		if not is_node_ready():
			await ready
		_draw_baseline()
		_draw_text()

## The size of the text.
@export_range(1, 100, 1, "or_greater", "suffix:pt") var fontsize: int = 32:
	set(value):
		fontsize = value
		if not is_node_ready():
			await ready
		_update_text()

## The thickness of the baseline.
@export_range(1, 20, 0.1, "or_greater", "suffix:pt") var thickness: float = 2:
	set(value):
		thickness = value
		if not is_node_ready():
			await ready
		_update_baseline()

## The color of the text and of the baseline
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		if not is_node_ready():
			await ready
		_update_baseline()
		_update_text()

## The percent of the tendrilis to show
@export_range(0, 1, 0.001) var show_factor: float = 1.0:
	set(value):
		show_factor = value
		if not is_node_ready():
			await ready
		_draw_baseline()
		_draw_text()

## Show the translation of the tendrilis
@export var show_translation: bool = true:
	set(value):
		show_translation = value
		_update_text_translation()

@export_group("Scenes", "scene")
@export var scene_tendrilis_character: PackedScene = load("res://letters/tendrilis-character.tscn")

#endregion
#region Script variables

@onready var chars_container: Node2D = %Chararacters
@onready var baseline: Line2D = %Baseline

#endregion
#region Private variables

## The length of the baseline calculated by the curve.
var _baseline_length: float

#endregion
#region Magics

func _ready() -> void:
	_baseline_length = curve.get_baked_length()

	curve.changed.connect(_on_curve_changed)

#endregion
#region Events

## Toolbutton method to grow the tendril from start to end.
func _on_tb_grow_vine_pressed() -> void:
	show_factor = 0
	var tween = create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "show_factor", 1.0, 2)

#endregion
#region Private methods

## When the shape of the curve is modified, update the baseline and the characters to match the new shape.
func _on_curve_changed() -> void:
	_baseline_length = curve.get_baked_length()
	_draw_baseline()
	_update_text()

## Draw the baseline.
func _draw_baseline() -> void:
	var subdivisions = len(text)
	baseline.clear_points()
	baseline.width = 1
	baseline.default_color = color
	baseline.antialiased = true
	baseline.add_point(curve.get_point_position(0))

	for index in subdivisions * show_factor:
		baseline.add_point(curve.sample_baked(_baseline_length * (1.0 + index) / subdivisions))

## Update the baseline parameters that don't require to redraw it: color and thickness.
func _update_baseline() -> void:
	baseline.default_color = color
	baseline.width = thickness

## Create and draw each character of the text.
func _draw_text() -> void:
	for child in chars_container.get_children():
		child.queue_free()

	for index in floor(text.length() * show_factor):
		var letter = text[index].to_lower()
		var character: TendrilisCharacter = scene_tendrilis_character.instantiate()
		character.letter = letter
		character.fontsize = fontsize
		character.color = color
		_update_text_char_position(character, index)
		chars_container.add_child(character)

## Update each character parameters that don't require to redraw the text: fontsize, color, position and rotation.
func _update_text() -> void:
	for index in floor(text.length() * show_factor):
		var child = chars_container.get_child(index)
		child.fontsize = fontsize
		child.color = color
		_update_text_char_position(child, index)

## Update the translation of the tendrilis below the baseline.
func _update_text_translation() -> void:
	for child in chars_container.get_children():
		child.show_translation = show_translation

## Update the tendrilis character.
func _update_text_char_position(character: TendrilisCharacter, index: int) -> void:
	var transf = curve.sample_baked_with_rotation(_baseline_length * index / text.length())
	character.position = transf.get_origin()
	character.rotation = transf.get_rotation()

#endregion

@tool
class_name Tendrilis
extends Path2D

#region Script variables - Export

@export_tool_button("Grow vine", "GuiTreeArrowRight") var tb_grow_vine = _on_tb_grow_vine_pressed
@export_tool_button("Shrink vine", "GuiTreeArrowLeft") var tb_shrink_vine = _on_tb_shrink_vine_pressed

## The text to translate to tendrilis.
@export_multiline var text: String = "":
	set(value):
		text = value
		if not is_node_ready():
			await ready
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

## The color of the text and of the baseline.
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		if not is_node_ready():
			await ready
		_update_baseline()
		_update_text()

## The percent of the tendrilis to show.
@export_range(0, 1, 0.001) var show_factor: float = 0.0:
	set(value):
		_show_factor_previous = show_factor
		show_factor = value
		if not is_node_ready():
			await ready
		baseline.show_factor = show_factor
		_draw_update_text()

## Show the translation of the tendrilis
@export var show_translation: bool = true:
	set(value):
		show_translation = value
		_update_text_translation()

@export_group("Scenes", "scene")
@export var scene_tendrilis_character: PackedScene = load("res://letters/tendrilis_character.tscn")

#endregion
#region Script variables - On ready

@onready var chars_container: Node2D = %Chararacters
@onready var baseline: GrowingLine2D = %Baseline

#endregion
#region Script variables - Private

var _show_factor_previous: float = 0

## The length of the baseline calculated by the curve.
var _baseline_length: float

#endregion
#region Magics

func _ready() -> void:
	_baseline_length = curve.get_baked_length()
	baseline.cached_points = curve.get_baked_points()
	baseline.width = 1
	baseline.default_color = color
	baseline.antialiased = true
	baseline.begin_cap_mode = Line2D.LINE_CAP_ROUND
	baseline.end_cap_mode = Line2D.LINE_CAP_ROUND

	curve.changed.connect(_on_curve_changed)

#endregion
#region Events

## Toolbutton method to grow the tendril from current state to full.
func _on_tb_grow_vine_pressed() -> void:
	var tween = create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "show_factor", 1.0, 2)


## Toolbutton method to shrink the tendril from current state to start.
func _on_tb_shrink_vine_pressed() -> void:
	var tween = create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "show_factor", 0.0, 2)

#endregion
#region Private methods

## When the shape of the curve is modified, update the baseline and the characters to match the new shape.
func _on_curve_changed() -> void:
	_baseline_length = curve.get_baked_length()
	baseline.cached_points = curve.get_baked_points()
	_update_text()


## Update the baseline parameters color and thickness.
func _update_baseline() -> void:
	baseline.default_color = color
	baseline.width = thickness


# Draw a character.
func _draw_character(index: int) -> void:
	var letter = text[index]
	var character: TendrilisCharacter = scene_tendrilis_character.instantiate()
	character.letter = letter
	character.fontsize = fontsize
	character.color = color
	_update_text_char_position(character, index)
	chars_container.add_child(character)


## Create and draw each character of the text.
func _draw_text() -> void:
	for child in chars_container.get_children():
		child.queue_free()

	for index in floor(text.length() * show_factor):
		_draw_character(index)


## Draw the text but not everything every time.
## If the text grows, only add the needed characters.
## If the text shrinks, only remove the needed characters.
func _draw_update_text() -> void:
	if _show_factor_previous < show_factor:
		var subdivisions = text.length()
		var start = floor(subdivisions * _show_factor_previous)
		var end = floor(subdivisions * show_factor)
		for index in range(start, end):
			_draw_character(index)
	# If only a part of the baseline should be cleared
	elif show_factor < _show_factor_previous:
		var subdivisions = text.length()
		var start = floor(subdivisions * show_factor)
		var end = floor(subdivisions * _show_factor_previous)
		for index in range(start, end):
			chars_container.get_child(index).queue_free()


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

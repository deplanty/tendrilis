@tool
class_name Tendrilis
extends Path2D

#region Script variables

# Signals

signal grow_finished
signal shrink_finished

# Export variables

@export_tool_button("Grow vine", "GuiTreeArrowRight") var tb_grow_vine = _on_tb_grow_vine_pressed
@export_tool_button("Shrink vine", "GuiTreeArrowLeft") var tb_shrink_vine = _on_tb_shrink_vine_pressed

## The text to translate to tendrilis.
@export_multiline var text: String = "":
	set(value):
		text = value
		if is_node_ready():
			_init_text()
			_draw_text()

## The size of the text.
@export_range(1, 100, 1, "or_greater", "suffix:pt") var fontsize: int = 32:
	set(value):
		fontsize = value
		if is_node_ready():
			_update_text()

## The thickness of the baseline.
@export_range(1, 20, 0.1, "or_greater", "suffix:pt") var thickness: float = 4:
	set(value):
		thickness = value
		if is_node_ready():
			_update_baseline()

## The color of the text and of the baseline.
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		if is_node_ready():
			_update_baseline()
			_update_text()

## The percent of the tendrilis to show.
@export_range(0, 1, 0.001) var show_factor: float = 0.:
	set(value):
		_show_factor_previous = show_factor
		show_factor = value
		if is_node_ready():
			baseline.show_factor = show_factor
			_draw_text()

## Show the translation of the tendrilis
@export var show_translation: bool = true:
	set(value):
		show_translation = value
		if is_node_ready():
			_update_text_translation()

@export_group("Scenes", "scene")
@export var scene_tendrilis_character: PackedScene = load("res://letters/tendrilis_character.tscn")

# On ready variables

@onready var chars_container: Node2D = %Chararacters
@onready var baseline: GrowingLine2D = %Baseline

# Private variables

var _show_factor_previous: float = 0

## The length of the baseline calculated by the curve.
var _baseline_length: float

#endregion
#region Magics

func _ready() -> void:
	_baseline_length = curve.get_baked_length()
	baseline.cached_points = curve.get_baked_points()
	baseline.antialiased = true
	baseline.begin_cap_mode = Line2D.LINE_CAP_ROUND
	baseline.end_cap_mode = Line2D.LINE_CAP_ROUND
	_update_baseline()

	curve.changed.connect(_on_curve_changed)

	_init_text()
	_draw_text()
	_update_text_translation()

#endregion
#region Events

## Toolbutton method to grow the tendril from current state to full.
func _on_tb_grow_vine_pressed() -> void:
	grow(5)


## Toolbutton method to shrink the tendril from current state to start.
func _on_tb_shrink_vine_pressed() -> void:
	shrink(5)

#endregion
#region Private methods

## When the shape of the curve is modified, update the baseline and the characters to match the new shape.
func _on_curve_changed() -> void:
	_baseline_length = curve.get_baked_length()
	baseline.cached_points = curve.get_baked_points()
	_update_text()


## Update the baseline parameters color and thickness.
func _update_baseline() -> void:
	baseline.show_factor = show_factor
	baseline.default_color = color
	baseline.width = thickness


## Create each character of the text.
## Wait for the update function to draw them according to the [member show_factor] value.
func _init_text() -> void:
	for child in chars_container.get_children():
		child.queue_free()

	for index in text.length():
		var chr = text[index]
		var character: TendrilisCharacter = scene_tendrilis_character.instantiate()
		character.letter = chr
		character.fontsize = fontsize
		character.color = color
		character.show_factor = 0.
		_update_text_char_position(character, index)
		chars_container.add_child(character)


## Draw the text but not everything every time.
## If the text grows, only add the needed characters.
## If the text shrinks, only remove the needed characters.
func _draw_text() -> void:
	if _show_factor_previous < show_factor:
		# Get which characters to display
		var subdivisions = text.length()
		var start = floor(subdivisions * _show_factor_previous)
		var end = subdivisions * show_factor
		for index in range(start, end):
			var tendrilis_char = chars_container.get_child(index)
			tendrilis_char.show_factor = 1
		# Start to draw the next chararacter with the decimal part
		var index = floor(end)
		var rest = end - index
		if index == chars_container.get_child_count():
			return
		var chr = chars_container.get_child(index)
		chr.show_factor = rest
	# If only a part of the baseline should be cleared
	elif show_factor < _show_factor_previous:
		# Get which character to hide
		var subdivisions = text.length()
		var start = subdivisions * show_factor
		var start_index = floor(start)
		var end_index = floor(subdivisions * _show_factor_previous)
		for index in range(start, end_index):
			var tendrilis_char = chars_container.get_child(index)
			tendrilis_char.show_factor = 0
		# Show only a part of the start character
		var rest = start - start_index
		var chr = chars_container.get_child(start_index)
		chr.show_factor = rest
		# Needed to completely hide a previous character
		if end_index + 1 < chars_container.get_child_count():
			chr = chars_container.get_child(end_index + 1)
			chr.show_factor = 0


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
#region Public variables

func grow(duration: float, from_zero: bool = false) -> void:
	if from_zero:
		show_factor = 0

	var tween = create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "show_factor", 1.0, duration)
	await tween.finished
	grow_finished.emit()


func shrink(duration: float, from_zero: bool = false) -> void:
	if from_zero:
		show_factor = 1

	var tween = create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "show_factor", 0.0, duration)
	await tween.finished
	shrink_finished.emit()


func grow_after(tendrilis: Tendrilis, duration: float) -> void:
	await tendrilis.grow_finished
	grow(duration)

#endregion

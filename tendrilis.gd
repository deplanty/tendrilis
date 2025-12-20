@tool
class_name Tendrilis
extends Path2D


@export_tool_button("Grow vine", "GuiVisibilityVisible") var tb_grow_vine = _on_tb_grow_vine_pressed

## The text to translate to tendrilis.
@export_multiline var text: String = "":
	set(value):
		text = value.to_lower()
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


@onready var chars_container: Node2D = %Chararacters
@onready var baseline: Line2D = %Baseline


var characters_data: Dictionary


func _ready() -> void:
	curve.changed.connect(_on_curve_changed)
	
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://letters/characters.json"))
	for letter_data in data:
		characters_data.set(letter_data["symbol"], letter_data)


func _on_curve_changed() -> void:
	_draw_baseline()
	_update_text()


func _draw_baseline() -> void:
	var subdivisions = len(text)
	var curve_size = curve.get_baked_length()
	baseline.clear_points()
	baseline.width = 1
	baseline.default_color = color
	baseline.antialiased = true
	baseline.add_point(curve.get_point_position(0))
	for index in subdivisions:
		baseline.add_point(curve.sample_baked(curve_size * (1.0 + index) / subdivisions))


func _update_baseline() -> void:
	baseline.default_color = color
	baseline.width = thickness


func _draw_text() -> void:
	for child in chars_container.get_children():
		child.queue_free()

	var index: int = 0
	for letter in text:
		var tendri_letter: TendrilisLetter = load("res://letters/tendrilis-letter.tscn").instantiate()
		chars_container.add_child(tendri_letter)
		tendri_letter.set_character_data(characters_data[letter])
		tendri_letter.fontsize = fontsize
		tendri_letter.color = color
		var transf = curve.sample_baked_with_rotation(curve.get_baked_length() * index / len(text))
		tendri_letter.position = transf.get_origin()
		tendri_letter.rotation = transf.get_rotation()
		index += 1


func _update_text() -> void:
	var index: int = 0
	for child in chars_container.get_children():
		child.fontsize = fontsize
		child.color = color
		var transf = curve.sample_baked_with_rotation(curve.get_baked_length() * index / len(text))
		child.position = transf.get_origin()
		child.rotation = transf.get_rotation()
		index += 1


func _on_tb_grow_vine_pressed() -> void:
	pass

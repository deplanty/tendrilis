@tool
class_name GrowingLine2D
extends Line2D


## The actual points of the line.
@export var cached_points: PackedVector2Array:
	set(value):
		cached_points = value
		if not is_node_ready():
			await ready
		clear_points()
		_update_line()

## The percent of the line that is shown.
@export_range(0.0, 1.0, 0.01) var show_factor: float = 0:
	set(value):
		show_factor = value
		if not is_node_ready():
			await ready
		_update_line()


func _ready() -> void:
	_update_line()


## Update what part of the line is shown.
## From the start to the [member show_factor] percent using the points in the [member cached_points].
func _update_line() -> void:
	var target_size = floor(cached_points.size() * show_factor)
	# If the line must grow.
	if target_size > points.size():
		for index in range(points.size(), target_size):
			add_point(cached_points[index])
	# If the line must shrink
	elif target_size < points.size():
		for index in range(target_size, points.size()):
			remove_point(target_size)

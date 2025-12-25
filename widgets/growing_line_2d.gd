@tool
class_name GrowingLine2D
extends Line2D


@export_range(0.0, 1.0, 0.01) var show_factor: float = 1.0

var cached_points: PackedVector2Array

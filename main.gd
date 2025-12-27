extends Node2D



func _ready() -> void:
	if get_child_count() >= 2:
		for index in get_child_count() - 1:
			get_child(index + 1).grow_after(get_child(index), 3)
		get_child(0).grow(3)

@tool
#class_name TendrilisData  # Autoload
extends Node

const _TABLE_CHAR = {
	"à": "a",
	"ç": "c",
	"é": "e",
	"è": "e",
	"ê": "e",
	"ë": "e",
	"î": "i",
	"ï": "i",
	"ô": "o",
	"ù": "u",
	"'": " ",
}



var characters: Dictionary


#region Magic

func _ready() -> void:
	var char_data = JSON.parse_string(FileAccess.get_file_as_string("res://letters/characters.json"))
	for data in char_data:
		characters.set(data["symbol"], _character_from_dict(data))

#endregion
#region Private methods

func _character_from_dict(data: Dictionary) -> Character:
	var character = Character.new()
	character.symbol = data["symbol"]
	character.char_name = data["name"]
	character.base_size = data["base_size"]
	character.base_subdivision = data["base_subdivision"]
	character.shapes = Array()
	for shape in data["shapes"]:
		var points = Array()
		for point in shape:
			var point_data = Dictionary()
			for key in point:
				point_data[key] = Vector2(point[key][0], point[key][1])
			points.push_back(point_data)
		character.shapes.push_back(points)
	return character

#endregion
#region Public methods

## Return the Character object from a character (String).
## If the character is special or with an accent, clean it first.
func get_character(chr: String) -> Character:
	chr = chr.to_lower()
	chr = _TABLE_CHAR.get(chr, chr)
	return characters[chr]

#endregion

## The data of a tendrilis character.
class Character:
	var symbol: String
	var char_name: String
	var base_size: float
	var base_subdivision: int
	var shapes: Array

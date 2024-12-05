class_name ColourPalette extends HBoxContainer

@onready var archetype : Colour = $Colour

# White is included by the default colour button.
const colours : Array[String] = [
	"ffffff",
	"a48080",
	"feb854",
	"e8ea4a",
	"58f5b1",
	"64a4a4",
	"cc68e4",
	"fe626e",
	"c8c8c8",
	"e03c32",
	"fe7000",
	"63b31d",
	"a4f022",
	"27badb",
	"fe48de",
	"d10f4c",
	"707070",
	"991515",
	"ca4a00",
	"a3a324",
	"008456",
	"006ab4",
	"9600dc",
	"861650",
	"000000",
	"4c0000",
	"783450",
	"8a6042",
	"003d10",
	"202040",
	"340058",
	"4430ba",
]

# TODO: Fade the pallette UI out when the user is drawing

func _ready() -> void:
	for colour : String in colours:
		var s : Colour = archetype.duplicate()
		add_child(s)
		s.self_modulate = Color(colour)
	archetype.hide()

func select_colour(button : Colour) -> void:
	%Canvas.colour_primary = button.self_modulate

class_name ColourPalette extends HBoxContainer

@onready var default_white: ColourButton = $ColorRect

# White is included by the default colour button.
const colours : Array[Color] = [
	Color.BLACK,
	Color.RED,
	Color.ORANGE,
	Color.YELLOW,
	Color.GREEN,
	Color.BLUE,
]

func _ready() -> void:
	for colour in colours:
		var s : ColorRect = default_white.duplicate()
		add_child(s)
		s.color = colour

func select_colour(button : ColourButton) -> void:
	%Canvas.colour_primary = button.color

class_name ColourPalette extends HBoxContainer

const colours : Array[Color] = [
	Color.WHITE,
	Color.BLACK,
	Color.RED,
	Color.ORANGE,
	Color.YELLOW,
	Color.GREEN,
	Color.BLUE,
]

func _ready() -> void:
	for colour in colours:
		var s : ColorRect = get_child(0).duplicate()
		add_child(s)
		s.color = colour
	
	get_child(0).visible = false

func select_colour(button : ColourButton) -> void:
	%Canvas.colour_primary = button.color

class_name ColourPalette extends HBoxContainer
@export var default_palette : Texture2D

@onready var archetype : Colour = $Colour

# TODO: Fade the pallette UI out when the user is drawing

func _ready() -> void:
	regenerate_palette(parse_palette(default_palette))

func parse_palette(tex : Texture2D) -> Array[Color]:
	var img : Image = tex.get_image()
	var colours : Array[Color] = []
	for x : int in range(img.get_size().x):
		colours.append(img.get_pixel(x,0))
	return colours

func regenerate_palette(colours : Array[Color]) -> void:
	for colour : Color in colours:
		var s : Colour = archetype.duplicate()
		add_child(s)
		s.self_modulate = colour
	archetype.hide()

func select_colour(button : Colour) -> void:
	%Canvas.colour_primary = button.self_modulate

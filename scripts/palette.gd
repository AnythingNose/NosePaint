class_name ColourPalette extends VBoxContainer

@export var default_palette : Texture2D

@onready var area: VBoxContainer = $PaletteArea
@onready var container: HBoxContainer = $PaletteArea/PaletteContainer
@onready var archetype: Colour = $PaletteArea/PaletteContainer/Colour

# TODO: Fade the pallette UI out when the user is drawing
var main : Main
var mouse_inside : bool = false

var can_drag : bool
var is_dragging : bool

var preferred_height : float

func _ready() -> void:
	main = get_tree().current_scene
	regenerate_palette(parse_palette(default_palette))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if can_drag:
			is_dragging = true
	if event.is_action_released("click"):
		is_dragging = false

# TODO Light cleanup
# TODO Fix the weird scaling on the dragging due to using stretch ratio.
func _process(delta: float) -> void:
	var mouse_currently_inside : bool = area.get_rect().has_point(get_global_mouse_position()) or is_dragging and not main.menu.open
	if mouse_currently_inside:
		if not mouse_inside:
			mouse_inside = true
			main.block_draw = mouse_inside
	else:
		if mouse_inside:
			mouse_inside = false
			main.block_draw = mouse_inside
	
	
	var mouse_pos : Vector2 = get_global_mouse_position()
	
	if is_dragging:
		var mouse_y_ratio : float = clamp(inverse_lerp(get_viewport().size.y, get_viewport().size.y / 2, mouse_pos.y),0,1)
		area.size_flags_stretch_ratio = mouse_y_ratio

func parse_palette(tex : Texture2D) -> Array[Color]:
	var img : Image = tex.get_image()
	var colours : Array[Color] = []
	for x : int in range(img.get_size().x):
		colours.append(img.get_pixel(x,0))
	return colours

func regenerate_palette(colours : Array[Color]) -> void:
	for colour : Color in colours:
		var s : Colour = archetype.duplicate()
		container.add_child(s)
		s.palette = self
		s.self_modulate = colour
	archetype.hide()

func select_colour(button : Colour) -> void:
	%Canvas.colour_primary = button.self_modulate

func _on_drag_area_mouse_entered() -> void:
	can_drag = true


func _on_drag_area_mouse_exited() -> void:
	can_drag = false

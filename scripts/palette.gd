class_name ColourPalette extends VBoxContainer

@export var default_palette : Texture2D

@onready var area: VBoxContainer = $PaletteArea
@onready var container: HBoxContainer = $PaletteArea/PaletteContainer
@onready var archetype: Colour = $PaletteArea/PaletteContainer/Colour

const FADE_IN_DELAY : float = 0.33
const FADE_IN_DURATION : float = 0.5
const FADE_OUT_DURATION : float = 0.5

var main : Main
var mouse_inside : bool = false
var previously_drawing : bool = false
var show_palette : bool = true

var modulate_target : float = 1.0
var can_drag : bool
var is_dragging : bool
var preferred_height : float
var fade_in_delay_timer : float
var fading_in : bool

# TODO Fix the weird scaling on the dragging due to using stretch ratio.

func _ready() -> void:
	main = get_tree().current_scene
	regenerate_palette(parse_palette(default_palette))
	%Canvas.on_draw_start.connect(draw_start)
	%Canvas.on_draw_end.connect(draw_end)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if can_drag:
			is_dragging = true
	if event.is_action_released("click"):
		is_dragging = false

func _process(delta: float) -> void:
	modulate.a = modulate_target
	
	var mouse_currently_inside : bool = \
	area.get_rect().has_point(get_global_mouse_position()) \
	and not main.menu.open and not %Canvas.drawing
	
	if mouse_currently_inside:
		if not mouse_inside:
			mouse_inside = true
			main.block_draw = mouse_inside
	else:
		if mouse_inside:
			mouse_inside = false
			main.block_draw = mouse_inside
	
	if fading_in:
		if fade_in_delay_timer < FADE_IN_DELAY:
			fade_in_delay_timer += delta
		else:
			draw_fade_in()

func draw_start() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate_target", 0, FADE_OUT_DURATION)

func draw_end() -> void:
	fade_in_delay_timer = 0
	fading_in = true

func draw_fade_in() -> void:
	fading_in = false
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate_target", 1, FADE_OUT_DURATION)

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

# Signal Callbacks
func _on_drag_area_mouse_entered() -> void:
	can_drag = true

func _on_drag_area_mouse_exited() -> void:
	can_drag = false

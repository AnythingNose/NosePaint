class_name ColourPalette extends VSplitContainer

@onready var container: HBoxContainer = $PaletteContainer
@onready var archetype: Colour = $PaletteContainer/Colour
@onready var selected_colour: ColorRect = $PaletteContainer/SelectedColour
@onready var selected_outline: Panel = $PaletteContainer/SelectedColour/SelectedOutline

const FADE_IN_DELAY : float = 0.33
const FADE_IN_DURATION : float = 0.5
const FADE_OUT_DURATION : float = 0.5
const PALETTE_SIZE_MARGIN : int = 15

var main : Main
var mouse_inside : bool = false

var modulate_target : float = 1.0
var fade_in_delay_timer : float
var fading_in : bool
var preferred_height : float

var dragging_split : bool = false
var drag_rect : Rect2


func _ready() -> void:
	main = get_tree().current_scene
	get_tree().get_root().size_changed.connect(update_split_offset) 
	%Canvas.on_draw_start.connect(draw_start)
	%Canvas.on_draw_end.connect(draw_end)
	archetype.hide()
	selected_colour.color = %Canvas.colour_primary


func _process(delta: float) -> void:
	if main.menu.open:
		return
	
	# Annoyingly SplitContainer doesn't have any callbacks for starting / stopping
	# dragging so we have to manually calculate a rectangle around the drag area.
	drag_rect = Rect2(
		0,
		(get_viewport_rect().size.y / 2) + split_offset - get_theme_constant("minimum_grab_thickness") * 0.5,
		get_viewport_rect().size.x,
		get_theme_constant("minimum_grab_thickness")
	)
	var can_drag_split : bool = drag_rect.has_point(get_global_mouse_position())
	if dragging_split and Input.is_action_just_released("click"):
		dragging_split = false
	
	# Figure out if we should allow drawing or show the cursor.
	# No need to look at this for too long.
	var mouse_currently_inside : bool = \
	(container.get_rect().has_point(get_global_mouse_position()) \
	or can_drag_split or dragging_split) \
	and not %Canvas.drawing
	
	# Mouse entered / exited momentary events
	if mouse_currently_inside:
		if not mouse_inside: # Mouse entered
			mouse_inside = true
			main.block_draw = mouse_inside
	else:
		if mouse_inside: # Mouse exited
			mouse_inside = false
			main.block_draw = mouse_inside
	
	# Fade in / out timer
	modulate.a = modulate_target
	if fading_in:
		if fade_in_delay_timer < FADE_IN_DELAY:
			fade_in_delay_timer += delta
		else:
			draw_fade_in()


# Functions
func update_split_offset() -> void:
	var y_mid : int = (get_viewport_rect().size.y / 2)
	split_offset = clampi(split_offset, -y_mid + PALETTE_SIZE_MARGIN, y_mid - PALETTE_SIZE_MARGIN)


# Palette parsing / changing
func parse_palette(tex : Texture2D) -> Array[Color]:
	var img : Image = tex.get_image()
	var colours : Array[Color] = []
	for x : int in range(img.get_size().x):
		colours.append(img.get_pixel(x,0))
	return colours


func regenerate_palette(colours : Array[Color]) -> void:
	for child : Node in container.get_children():
		if child != archetype and child is Colour:
			child.queue_free()
	
	for colour : Color in colours:
		var s : Colour = archetype.duplicate()
		container.add_child(s)
		s.palette = self
		s.self_modulate = colour
		s.show()


# Fade in / out functions
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


# Signal Callbacks
func select_colour(button : Colour) -> void:
	%Canvas.colour_primary = button.self_modulate


func _on_dragged(_offset: int) -> void: # Split container dragged
	dragging_split = true
	update_split_offset()

class_name InfoFollow extends Control

@onready var tooltips: VBoxContainer = $Tooltips
@onready var radius_label: Label = $Tooltips/RadiusLabel
@onready var connect_label: Label = $Tooltips/ConnectLabel
@onready var average_label: Label = $Tooltips/AverageLabel
@onready var eyedropper: HBoxContainer = $Eyedropper
@onready var colour_panel: Panel = $Eyedropper/ColourOutline/Colour

@export var x_offset : float = 10
@export var radius_update_lifetime : float = 0.5

var brush_offset : float

var radius_update_timer : float = 0

var eyedropping : bool:
	set(value):
		eyedropping = value
		_update_dropper_visibility()

func _ready() -> void:
	radius_label.visible = false
	_update_dropper_visibility()

func _process(delta: float) -> void:
	brush_offset = %Canvas.radius * %Canvas.zoom_factor
	global_position = get_global_mouse_position()
	tooltips.position.y = x_offset + brush_offset
	
	if eyedropping:
		eyedropper.position.x = brush_offset + 1 if %Canvas.radius == 0 else brush_offset
		eyedropper.size.y = brush_offset * 2
		eyedropper.position.y = -(eyedropper.size.y / 2)
	
	colour_panel.modulate = %Canvas.eyedrop_colour
	
	if radius_label.visible:
		if radius_update_timer < radius_update_lifetime:
			radius_update_timer += delta
		else:
			radius_label.visible = false

func _update_dropper_visibility() -> void:
	eyedropper.visible = eyedropping
	if not eyedropping:
		average_label.visible = false

func push_radius_update(radius : int) -> void:
	# As far as the canvas is concerned, a brush size of 1 means the smallest circle possible
	# (a cross made up of 5 pixels). It's more accurate for a brush size of 1 to be 1 pixel,
	# so we cheat it here.
	radius_label.text = str(radius + 1)
	radius_update_timer = 0
	radius_label.visible = true

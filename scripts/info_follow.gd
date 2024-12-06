class_name InfoFollow extends Control

@onready var radius_label: Label = $VBox/RadiusLabel
@onready var connect_label: Label = $VBox/ConnectLabel

@export var x_offset : float = 10
@export var radius_update_lifetime : float = 0.5

var brush_offset : float

var radius_update_timer : float = 0

func _process(delta: float) -> void:
	brush_offset = %Canvas.radius * %Canvas.zoom_factor
	global_position = get_global_mouse_position() + Vector2(x_offset + brush_offset, 0)
	
	if radius_label.visible:
		if radius_update_timer < radius_update_lifetime:
			radius_update_timer += delta
		else:
			radius_label.visible = false

func push_radius_update(radius : int) -> void:
	# As far as the canvas is concerned, a brush size of 1 means the smallest circle possible
	# (a cross made up of 5 pixels). It's more accurate for a brush size of 1 to be 1 pixel,
	# so we cheat it here.
	radius_label.text = str(radius + 1)
	radius_update_timer = 0
	radius_label.visible = true

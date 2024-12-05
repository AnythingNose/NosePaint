class_name InfoFollow extends Control

@onready var radius_label: Label = $VBox/RadiusLabel
@onready var connect_label: Label = $VBox/ConnectLabel

@export var x_offset : float = 10
@export var radius_update_lifetime : float = 0.5

var offset : float
var brush_offset : float

var radius_update_timer : float = 0

func _process(delta: float) -> void:
	offset = x_offset * %Canvas.zoom_factor
	brush_offset = %Canvas.radius * %Canvas.zoom_factor
	global_position = get_global_mouse_position() + Vector2(offset + brush_offset, 0)
	
	if radius_label.visible:
		if radius_update_timer < radius_update_lifetime:
			radius_update_timer += delta
		else:
			radius_label.visible = false

func push_radius_update(radius : int) -> void:
	var txt : String = "" if radius == 0 else str(radius)
	radius_label.text = txt
	radius_update_timer = 0
	radius_label.visible = true

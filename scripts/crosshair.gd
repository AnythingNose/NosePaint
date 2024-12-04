class_name Crosshair extends Control

func _process(_delta: float) -> void:
	position = get_global_mouse_position()

func _draw() -> void:
	draw_circle(Vector2.ZERO, %Canvas.radius * %Canvas.zoom_factor, Color.WHITE, false)

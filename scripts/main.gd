class_name Main extends Control

var block_draw : bool = false:
	set(value):
		block_draw = value
		show_mouse(value)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func show_mouse(should_show : bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if should_show or (%Canvas.radius == 0) else Input.MOUSE_MODE_HIDDEN
	%Crosshair.visible = !should_show and (%Canvas.radius != 0)

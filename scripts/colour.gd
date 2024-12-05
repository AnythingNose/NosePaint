class_name Colour extends Panel

var main : Main
var palette : ColourPalette

func _ready() -> void:
	set_process_input(false)
	
	palette = get_parent()
	main = get_tree().current_scene

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		palette.select_colour(self)

func _on_mouse_entered() -> void:
	set_process_input(true)
	main.block_draw = true

func _on_mouse_exited() -> void:
	set_process_input(false)
	main.block_draw = false

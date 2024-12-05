extends Control

@onready var menu: Panel = $Menu
@onready var menu_label: Label = $MenuLabel

# Setting buttons 
@onready var fullscreen_button: Button = $Menu/MenuHBox/Settings/SettingsVBox/Fullscreen/Fullscreen

var open : bool = false

var main : Main

func _ready() -> void:
	main = get_tree().current_scene
	show_menu(open)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		open = !open
		show_menu(open)
	if event.is_action_pressed("toggle_fullscreen"):
		_on_fullscreen_toggled(!fullscreen_button.button_pressed)

func show_menu(should_show : bool) -> void:
	menu.visible = should_show
	main.block_draw = should_show
	menu_label.visible = !should_show
	%Palette.visible = !should_show

# Settings
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	fullscreen_button.button_pressed = toggled_on
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

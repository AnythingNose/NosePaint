class_name Menu extends Control

@onready var menu: Panel = $Menu
@onready var menu_label: Label = $MenuLabel

# Setting buttons 
@onready var fullscreen_button: Button = $Menu/MenuHBox/ScrollContainer/VBoxContainer/SettingsVBox/Fullscreen/Fullscreen

var main : Main
var open : bool = false

var hide_menu_label : bool:
	set(value):
		hide_menu_label = value
		show_menu_label(value)

func _ready() -> void:
	main = get_tree().current_scene
	show_menu(open)
	self.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		open = !open
		show_menu(open)
	if event.is_action_pressed("toggle_fullscreen"):
		_on_fullscreen_toggled(!fullscreen_button.button_pressed)

func show_menu(should_show : bool) -> void:
	menu.visible = should_show
	main.block_draw = should_show
	show_menu_label(!should_show)
	%Palette.visible = !should_show

func show_menu_label(should_show : bool) -> void:
	menu_label.visible = false if hide_menu_label else should_show

# Settings
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	fullscreen_button.button_pressed = toggled_on
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_hide_menu_label_toggled(toggled_on: bool) -> void:
	hide_menu_label = toggled_on


func _on_new_image_pressed() -> void:
	pass # Replace with function body.


func _on_open_image_pressed() -> void:
	main.file_open_dialog()


func _on_save_image_pressed() -> void:
	main.file_save_dialog()


func _on_save_image_as_pressed() -> void:
	pass # Replace with function body.

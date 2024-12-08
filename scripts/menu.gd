class_name Menu extends Control

@onready var menu: Panel = $Menu
@onready var menu_label: Label = $MenuLabel
@onready var palette_list: ItemList = $Menu/MenuHBox/ScrollContainer/VBoxContainer/Palettes/PaletteList

# Setting buttons 
@onready var fullscreen_button: Button = $Menu/MenuHBox/ScrollContainer/VBoxContainer/SettingsVBox/Fullscreen/Fullscreen
@onready var new_dimensions_x: SpinBox = $"Menu/MenuHBox/ScrollContainer/VBoxContainer/FileExport/NewImageHBox/Dimensions X"
@onready var new_dimensions_y: SpinBox = $"Menu/MenuHBox/ScrollContainer/VBoxContainer/FileExport/NewImageHBox/Dimensions Y"

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


# Show / Hide
func show_menu(should_show : bool) -> void:
	menu.visible = should_show
	main.block_draw = should_show
	show_menu_label(!should_show)
	%Palette.visible = !should_show

func show_menu_label(should_show : bool) -> void:
	menu_label.visible = false if hide_menu_label else should_show

func update_palette_list() -> void:
	palette_list.clear()
	for key : String in main.palettes:
		palette_list.add_item(key.replace(".png", ""), main.palettes[key])
		if key == main.get_palette_filename(main.default_palettes[0].resource_path):
			palette_list.select(palette_list.item_count - 1)

# Setting button callbacks
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	fullscreen_button.button_pressed = toggled_on
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_hide_menu_label_toggled(toggled_on: bool) -> void:
	hide_menu_label = toggled_on

# Signal Callbacks

func _on_new_image_pressed() -> void:
	main.new_file()

func _on_open_image_pressed() -> void:
	main.file_open_dialog()

func _on_save_image_pressed() -> void:
	main.quicksave_file()

func _on_save_image_as_pressed() -> void:
	main.file_save_dialog()

func _on_palette_list_item_selected(index: int) -> void:
	main.load_palette(palette_list.get_item_text(index) + ".png")

class_name Menu extends Control

@onready var menu: Panel = $Menu
@onready var menu_label: Label = $MenuLabel
@onready var help_label: RichTextLabel = $Menu/MenuHBox/HelpLabel
@onready var palette_grid: GridContainer = $Menu/MenuHBox/ScrollContainer/VBoxContainer/Palettes/Panel/ScrollContainer/PaletteGrid
# Setting buttons 
@onready var fullscreen_button: Button = $Menu/MenuHBox/ScrollContainer/VBoxContainer/SettingsVBox/Fullscreen/Fullscreen
@onready var new_dimensions_x: SpinBox = $"Menu/MenuHBox/ScrollContainer/VBoxContainer/FileExport/NewImageHBox/Dimensions X"
@onready var new_dimensions_y: SpinBox = $"Menu/MenuHBox/ScrollContainer/VBoxContainer/FileExport/NewImageHBox/Dimensions Y"

const PALETTE_BUTTON : PackedScene = preload("res://scenes/palette_button.tscn")

var main : Main
var open : bool = false

var hide_menu_label : bool:
	set(value):
		hide_menu_label = value
		show_menu_label(value)

func _ready() -> void:
	main = get_tree().current_scene
	help_label.scroll_to_line(0)
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
	if should_show:
		%Canvas.end_eyedrop(false)

func show_menu_label(should_show : bool) -> void:
	menu_label.visible = false if hide_menu_label else should_show

func update_palette_list() -> void:
	for child : Node in palette_grid.get_children():
		child.queue_free()
		
	#palette_list.clear()
	for key : String in main.palettes:
		var button : PaletteButton = PALETTE_BUTTON.instantiate()
		palette_grid.add_child(button)
		button.filename = key
		var new_name : String = key.replace("-1x.png", "")
		new_name.replace(".png", "")
		button.label.text = new_name
		button.texture.texture = main.palettes[key]
		button.pressed.connect(_on_palette_list_item_selected.bind(button))
		
		if key == main.current_palette:
			(palette_grid.get_child(palette_grid.get_child_count()-1) as Button).button_pressed = true

func highlight_palette_button(button : PaletteButton) -> void:
	for child : PaletteButton in palette_grid.get_children():
		if child != button:
			child.button_pressed = false

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

func _on_palette_list_item_selected(button: PaletteButton) -> void:
	main.load_palette(button.filename)
	highlight_palette_button(button)


func _on_open_palettes_folder_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(main.palette_path))

func _on_refresh_palettes_pressed() -> void:
	main.read_palette_folder()


func _on_help_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

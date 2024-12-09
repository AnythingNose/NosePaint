class_name Main extends Control

const palette_path : String = "user://palettes"

@export var default_palettes : Array[CompressedTexture2D]

@onready var file_dialog: FileDialog = $FileDialog
@onready var canvas: Canvas = %Canvas
@onready var menu: Menu = $MenuContainer

# Variables
var palettes : Dictionary = {} # Key = filename, Value = texture
var current_image_path : String = ""
var current_palette : String = ""
var block_draw : bool = false:
	set(value):
		block_draw = value
		show_mouse(value)

# Lifecycle Methods
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	DisplayServer.window_set_title("Nose Paint " + ProjectSettings.get_setting("application/config/version"))
	# Force load the default palette
	%Palette.regenerate_palette(%Palette.parse_palette(default_palettes[0]))
	current_palette = get_palette_filename(default_palettes[0].resource_path)
	read_palette_folder()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("new_image"):
		new_file()
	elif event.is_action_pressed("open_image"):
		file_open_dialog()
	elif event.is_action_pressed("quicksave_image"):
		quicksave_file()
	elif event.is_action_pressed("save_image"):
		file_save_dialog()

# Mouse Handling
func show_mouse(should_show : bool) -> void:
	var mouse_cond : bool = (should_show or %Canvas.radius == 0) and not %Info.eyedropping
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if mouse_cond else Input.MOUSE_MODE_HIDDEN
	%Crosshair.visible = !mouse_cond

# File Operations
func new_file() -> void:
	%Canvas.new_blank_image(Vector2i(menu.new_dimensions_x.value, menu.new_dimensions_y.value))
	current_image_path = ""

func quicksave_file() -> void:
	if current_image_path == "":
		file_save_dialog()
	else:
		write_file(current_image_path)

func write_file(path : String) -> void:
	canvas.image.save_png(path)
	current_image_path = path

func file_open_dialog() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.clear_filters()
	file_dialog.add_filter("*.png, *.jpg", "Images")
	file_dialog.add_filter("*", "All Files")
	file_dialog.popup_centered()

func file_save_dialog() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.clear_filters()
	file_dialog.add_filter("*.png", "PNG")
	file_dialog.add_filter("*.jpg", "JPEG")
	file_dialog.popup_centered()

func _on_file_dialog_file_selected(path: String) -> void:
	match file_dialog.file_mode:
		FileDialog.FILE_MODE_OPEN_FILE:
			canvas.new_texture_from_path(path)
			current_image_path = ""  # Avoid accidental overwrite on quicksave
		FileDialog.FILE_MODE_SAVE_FILE:
			write_file(path)

# Palette Management
func read_palette_folder() -> void:
	palettes.clear()
	
	# Ensure the palette folder exists
	var folder : DirAccess = DirAccess.open("user://")
	if not folder.dir_exists(palette_path):
		folder.make_dir(palette_path)
		
		# Copy default palettes to user palette folder
		for palette : CompressedTexture2D in default_palettes:
			palette.get_image().save_png(palette_path + "/" + get_palette_filename(palette.resource_path))
	
	# Read palette folder
	folder = DirAccess.open(palette_path)
	for file : String in folder.get_files():
		if file.get_extension() == "png":
			var img : Image = Image.load_from_file(palette_path + "/" + file)
			var tex : Texture2D = ImageTexture.create_from_image(img)
			palettes[file] = tex
	
	menu.update_palette_list()

func get_palette_filename(path : String) -> String:
	return path.replace("res://palettes/", "").replace("user://palettes/", "")

func load_palette(filename : String) -> void:
	%Palette.regenerate_palette(%Palette.parse_palette(palettes[filename]))

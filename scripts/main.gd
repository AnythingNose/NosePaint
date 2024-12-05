class_name Main extends Control

@onready var file_dialog: FileDialog = $FileDialog
@onready var canvas: Canvas = %Canvas
@onready var menu: Menu = $MenuContainer

var block_draw : bool = false:
	set(value):
		block_draw = value
		show_mouse(value)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func show_mouse(should_show : bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if should_show or (%Canvas.radius == 0) else Input.MOUSE_MODE_HIDDEN
	%Crosshair.visible = !should_show and (%Canvas.radius != 0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("new_image"):
		pass
	elif event.is_action_pressed("open_image"):
		file_open_dialog()
	elif event.is_action_pressed("quicksave_image"):
		pass
	elif event.is_action_pressed("save_image"):
		file_save_dialog()

# File save / load functions
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

# File dialogue callbacks
func _on_file_dialog_file_selected(path: String) -> void:
	match file_dialog.file_mode:
		FileDialog.FILE_MODE_OPEN_FILE:
			canvas.new_texture(path)
		FileDialog.FILE_MODE_SAVE_FILE:
			canvas.image.save_png(path)
	

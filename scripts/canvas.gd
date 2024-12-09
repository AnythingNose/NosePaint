class_name Canvas extends TextureRect

# User-facing parameters
## Defines how stingy we are when filling in a brush stroke. Lower values are more precise but less performant.
## Higher values are much more performant but may result in bumpy strokes at higher brush sizes.
@export_range(0,1) var brush_interp_precision : float = 0.33
## Delays the texture updates, maintaining the same smoothness of brush strokes and improving performance,
## at the cost of making stroke updates feel laggier..
@export_range(0, 0.1) var update_interval: float = 0.01
@export_range(0, 1) var zoom_sensitivity: float = 0.1
@export_range(0, 1) var default_brush_size: int = 4
@export_range(0, 1) var brush_size_change_sensitivity: int = 1

signal on_draw_start
signal on_draw_end

# Constants
const min_brush_radius : int = 0
const max_brush_radius : int = 63
const min_zoom : float = 0.1
const max_zoom : float = 10

# Image and Rendering
var image : Image
var image_size : Vector2i
var dirty : bool = false
var update_timer: float = 0.0
var rect_size : Vector2i

# Mouse Position
var mpos : Vector2i
var prev_mpos : Vector2i
var m_delta : Vector2i
var mouse_in_canvas : bool

# Viewport zooming / panning
var zoom_factor: float = 1.0  # Default zoom level
var pan_start: Vector2  # Starting position for panning

# Drawing
var colour_primary : Color = Color.WHITE
var eyedrop_colour : Color
var eyedropping : bool = false
var radius : int = default_brush_size
var stroke_start : Vector2i
var connect_on_release : bool

var drawing : bool = false
var prev_drawing : bool = false

# References
var main : Main


# Lifecycle Methods
func _ready() -> void:
	main = get_tree().current_scene
	
	new_blank_image(get_viewport().size)

func new_blank_image(dimensions: Vector2i) -> void:
	# Create a new image and assign it to the texture
	image = Image.create_empty(dimensions.x, dimensions.y, false, Image.FORMAT_RGB8)
	init_canvas()


func new_texture_from_path(path : String) -> void:
	image.load(path)
	init_canvas()


func init_canvas() -> void:
	_update_image_size()
	texture = ImageTexture.create_from_image(image)
	size = Vector2(image_size)
	_center_canvas()
	_update_rect_size()
	%Crosshair.queue_redraw()
	dirty = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("alt_click"):
		position += event.relative
	if event is InputEventMouseButton and event.double_click:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_center_canvas()


func _process(delta: float) -> void:
	# Zoom and brush size input
	if Input.is_action_pressed("zoom_modifier"):
		if Input.is_action_just_pressed("increase_size"):
			zoom_increment(zoom_sensitivity)
		if Input.is_action_just_pressed("decrease_size"):
			zoom_increment(-zoom_sensitivity)
	else:
		if Input.is_action_just_pressed("increase_size"):
			brush_size_increment(-brush_size_change_sensitivity)
		
		if Input.is_action_just_pressed("decrease_size"):
			brush_size_increment(brush_size_change_sensitivity)
	
	# Get and clamp mouse position
	mpos = get_local_mouse_position().clamp(Vector2i.ZERO, rect_size)
	var was_in_canvas: bool = mouse_in_canvas
	mouse_in_canvas = get_local_mouse_position().x > 0 and get_local_mouse_position().x < rect_size.x \
					and get_local_mouse_position().y > 0 and get_local_mouse_position().y < rect_size.y
	m_delta = prev_mpos - mpos
	
	if drawing:
		if not prev_drawing:
			on_draw_start.emit()
			prev_drawing = true
	else:
		if prev_drawing:
			on_draw_end.emit()
			prev_drawing = false
	
	# Drawing input
	if Input.is_action_just_pressed("eyedrop"):
		eyedropping = true
		main.block_draw = true
		%Info.eyedrop_label.visible = true
	if eyedropping:
		var img : Image = get_viewport().get_texture().get_image()
		var global_mpos : Vector2i = Vector2i(get_global_mouse_position()).clamp(Vector2i.ZERO, get_viewport().size - Vector2i.ONE)
		eyedrop_colour = img.get_pixel(global_mpos.x, global_mpos.y)
	if Input.is_action_just_released("eyedrop"):
		eyedropping = false
		main.block_draw = false
		%Info.eyedrop_label.visible = false
		colour_primary = eyedrop_colour
	
	if main.block_draw or %Palette.mouse_inside:
		prev_mpos = mpos
		return
	
	
	connect_on_release = Input.is_action_pressed("connect")
	if Input.is_action_just_pressed("click"):
		stroke_start = mpos
	
	if Input.is_action_pressed("click"):
		%Info.connect_label.visible = connect_on_release
		
		drawing = mpos != stroke_start
		
		if mouse_in_canvas:
			if not was_in_canvas: 
				# If re-entering the canvas, connect to the edge
				var edge_pos : Vector2i = _clamp_to_edge(prev_mpos)
				_draw_line(_plot_line(edge_pos, mpos))
			else: 
				# Normal drawing behaviour within canvas
				_draw_line(_plot_line(prev_mpos, mpos))
		elif was_in_canvas:
			# If exiting the canvas, draw up to the edge
			var edge_pos : Vector2i = _clamp_to_edge(mpos)
			_draw_line(_plot_line(prev_mpos, edge_pos))
	else:
		if %Info.connect_label.visible:
			%Info.connect_label.hide()
	
	if Input.is_action_just_released("click"):
		drawing = false
		if connect_on_release:
			_draw_line(_plot_line(mpos, stroke_start))
	
	# Update texture periodically if dirty
	update_timer += delta
	if dirty and update_timer >= update_interval:
		texture.update(image)
		dirty = false
		update_timer = 0.0
	
	# Save the current mouse position for the next frame
	prev_mpos = mpos


func _clamp_to_edge(pos: Vector2i) -> Vector2i:
	return pos.clamp(Vector2i.ZERO, rect_size)


## Image / Viewport functions
func _update_image_size() -> void:
	image_size = image.get_size()


func _update_rect_size() -> void:
	rect_size = (get_rect().size) / Vector2(zoom_factor, zoom_factor)


func _center_canvas() -> void:
	# Reset zoom to fit the image within the viewport
	var viewport_size: Vector2 = get_viewport().size
	var image_ratio: float = float(image_size.x) / float(image_size.y)
	var viewport_ratio: float = float(viewport_size.x) / float(viewport_size.y)
	
	if image_ratio > viewport_ratio:
		# Image is wider than viewport
		zoom_factor = viewport_size.x / float(image_size.x)
	else:
		# Image is taller than or matches viewport ratio
		zoom_factor = viewport_size.y / float(image_size.y)
	
	clamp_zoom_factor()
	# Apply the zoom
	scale = Vector2(zoom_factor, zoom_factor)
	# Center position
	position = Vector2(get_viewport().size / 2) - (size * zoom_factor / 2)


func zoom_increment(amount : float) -> void:
	zoom_factor = zoom_factor + zoom_factor * amount
	clamp_zoom_factor()
	
	# Save mouse info before applying scale
	var prescale_mpos : Vector2 = get_viewport().get_mouse_position()
	var prescale_local_mpos : Vector2 = (prescale_mpos - position) / scale
	
	# Apply scale (zoom image)
	scale = Vector2(zoom_factor, zoom_factor)
	
	# Calculate offset based on prescale position
	var postscale_local_mpos : Vector2 = (prescale_mpos - position) / scale
	var offset : Vector2 = postscale_local_mpos - prescale_local_mpos
	
	# Apply offset so that we always zoom in on the mouse
	position += offset * scale
	
	_update_rect_size()
	%Crosshair.queue_redraw()


func clamp_zoom_factor() -> void:
	zoom_factor = clamp(zoom_factor, min_zoom, max_zoom)


func brush_size_increment(amount : int) -> void:
	radius = clamp(radius + amount, min_brush_radius, max_brush_radius)
	%Crosshair.queue_redraw()
	%Info.push_radius_update(radius)
	if not main.block_draw:
		main.show_mouse(radius == 0)


## Drawing functions
func _draw_line(points: Array[Vector2i]) -> void:
	for point : Vector2i in points:
		_draw_step(point)


func _draw_step(point: Vector2i) -> void:
	if radius == 0:
		if point.x < image_size.x and point.y < image_size.y:
			image.set_pixel(point.x, point.y, colour_primary)
	else:
		# Adapted from this explanation of the midpoint circle algorithm.
		# https://youtu.be/hpiILbMkF9w?list=PLuc6EyJgI1kzE1Fxz6JlussiemJNPjBmX
		var x: int = 0
		var y: int = radius
		var p: int = 1 - radius
		
		while x <= y:
			_draw_circle_points(point, x, y)
			x += 1
			if p < 0:
				p += 2 * x + 1
			else:
				y -= 1
				p += 2 * (x - y) + 1
	dirty = true


func _draw_circle_points(center: Vector2i, x: int, y: int) -> void:
	_draw_horizontal_line(center, -x, x, center.y + y)
	_draw_horizontal_line(center, -x, x, center.y - y)
	_draw_horizontal_line(center, -y, y, center.y + x)
	_draw_horizontal_line(center, -y, y, center.y - x)


func _draw_horizontal_line(center: Vector2i, start_x: int, end_x: int, y: int) -> void:
	# Skip if the row is out of bounds
	if y < 0 or y >= image_size.y:
		return
	
	# Clamp the horizontal range
	start_x = max(center.x + start_x, 0) - center.x
	end_x = min(center.x + end_x, image_size.x - 1) - center.x
	
	# Draw the horizontal line
	for dx : int in range(start_x, end_x + 1):
		image.set_pixel(center.x + dx, y, colour_primary)


# Use Bresenham's line algorithm
func _plot_line(p0: Vector2i, p1: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	var dx: int = abs(p1.x - p0.x)
	var dy: int = abs(p1.y - p0.y)
	var sx: int = 1 if p0.x < p1.x else -1
	var sy: int = 1 if p0.y < p1.y else -1
	var err: int = dx - dy
	var step_distance: float = radius * brush_interp_precision

	var current: Vector2i = p0
	points.append(current)
	while current != p1:
		var e2: int = 2 * err
		if e2 > -dy:
			err -= dy
			current.x += sx
		if e2 < dx:
			err += dx
			current.y += sy
		if current.distance_to(points[-1]) > step_distance:
			points.append(current)
	return points

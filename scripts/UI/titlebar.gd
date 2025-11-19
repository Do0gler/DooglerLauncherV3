extends Panel

const WINDOW_ICON := preload("uid://o434he2amxw6")
const FULLSCREEN_ICON := preload("uid://ck7qk62h6cr5y")

var following = false
var dragging_start_pos: Vector2
@export var resize_controls: Node


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	gui_input.connect(_on_gui_input)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_and_quit()


func _on_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			following = not following
			dragging_start_pos = get_local_mouse_position()
		if event.double_click:
			_on_windowed_button_pressed()


func _process(_delta) -> void:
	if following:
		var mouse_difference = get_global_mouse_position() - dragging_start_pos
		get_window().position += mouse_difference as Vector2i


func _on_exit_button_pressed() -> void:
	save_and_quit()


func save_and_quit() -> void:
	SettingsManager.save_settings()
	get_tree().quit()


func _on_windowed_button_pressed() -> void:
	# Toggle windowed mode
	if get_window().mode == Window.MODE_WINDOWED:
		get_window().mode = Window.MODE_FULLSCREEN
		resize_controls.hide()
		%WindowedButton.icon = WINDOW_ICON
	else:
		get_window().mode = Window.MODE_WINDOWED
		resize_controls.show()
		%WindowedButton.icon = FULLSCREEN_ICON


func _on_minimize_button_pressed() -> void:
	get_window().mode = Window.MODE_MINIMIZED

class_name Screenshot
extends Panel

func set_screenshot(screenshot: Texture2D) -> void:
	$Screenshot.texture = screenshot

func connect_button(callable: Callable):
	$Button.pressed.connect(callable)

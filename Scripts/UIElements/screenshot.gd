class_name Screenshot
extends Panel

func _ready() -> void:
	$Button.pressed.connect(open_screenshot)


func set_screenshot(screenshot: Texture2D) -> void:
	$Screenshot.texture = screenshot


# TODO: Implement opening and closing screenshots
func open_screenshot() -> void:
	pass


func close_screenshot() -> void:
	pass

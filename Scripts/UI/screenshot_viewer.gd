extends PanelContainer

func _ready() -> void:
	$VBoxContainer/TopBar/CloseButton.pressed.connect(close_screenshot)


func open_screenshot(screenshot: Texture2D):
	$VBoxContainer/ScreenshotContainer/ScreenshotTex.texture = screenshot
	%InputBlocker.show()
	show()


func close_screenshot():
	%InputBlocker.hide()
	hide()

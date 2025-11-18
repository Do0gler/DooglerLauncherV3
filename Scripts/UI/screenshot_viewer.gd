extends PanelContainer

var current_index := 0
var screenshots: Array[Texture2D]


func _ready() -> void:
	close_screenshot()
	$VBoxContainer/TopBar/CloseButton.pressed.connect(close_screenshot)
	%NextScreenshotButton.pressed.connect(change_screenshot)
	%PrevScreenshotButton.pressed.connect(change_screenshot.bind(true))


## Opens the screenshot viewer with the provided [param screenshots] set at [param index]
func open_screenshot(_screenshots: Array[Texture2D], index := 0):
	current_index = index
	screenshots = _screenshots
	
	set_screenshot()
	
	%InputBlocker.show()
	show()


func set_screenshot() -> void:
	%ScreenshotTex.texture = screenshots[current_index]
	$VBoxContainer/TopBar/Title.text = "Screenshot %d of %d" % [current_index + 1, screenshots.size()]

## Goes to the next screenshot.
## if [param previous] is true, then goes to the previous screenshot
func change_screenshot(previous := false) -> void:
	current_index += -1 if previous else 1
	current_index = wrapi(current_index, 0, screenshots.size())
	
	set_screenshot()


## Closes the screenshot viewer
func close_screenshot():
	%InputBlocker.hide()
	hide()

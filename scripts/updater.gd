extends Node

# TODO: Remove GAME_DATA_URL placeholder value
const GAME_DATA_URL := "http://dl.dropboxusercontent.com/scl/fi/e9g5x5oxw1qsusqouq9ev/game_versions.txt?rlkey=uf408yr47g8ia2uyq4glsf70c&st=j27ibb9n&dl=0"
const GAME_DATA_PATH := "user://game_data.txt"
var auto_check_updates := true

## Downloads the game data from the internet
func download_game_data() -> Dictionary:
	# Create http request
	var http := HTTPRequest.new()
	add_child(http)
	
	# Request data and save to file
	http.download_file = GAME_DATA_PATH
	var error := http.request(GAME_DATA_URL)
	await http.request_completed
	
	if error != OK:
		push_error("Error could not download game data: ", error_string(error))
	
	# Read data from file
	var file = FileAccess.open(GAME_DATA_PATH, FileAccess.READ)
	var contents: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	return contents


## Uses the Internet to update the games library
func check_for_updates() -> void:
	# Download games data
	var loading_screen = %LoadingScreen
	loading_screen.show()
	
	var game_data := await download_game_data()
	# TODO: Refresh the games library in Manager
	
	loading_screen.hide()

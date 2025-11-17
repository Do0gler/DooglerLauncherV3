extends Node

const GAME_DATA_URL := "http://dl.dropboxusercontent.com/scl/fi/10bsi2vu02hzf4fuxs97r/game_library.json?rlkey=xpo7siox1tkczw6k76li3m9eu&st=y9jj507c&dl=0"
var auto_check_updates := false

func _on_settings_loaded():
	if Updater.auto_check_updates:
		Updater.check_for_updates()

## Downloads the game library from the internet
func download_remote_library() -> void:
	# Create http request
	var http := HTTPRequest.new()
	add_child(http)
	
	# Request data and save to file
	http.download_file = SettingsManager.GAME_LIBRARY_PATH
	var error := http.request(GAME_DATA_URL)
	await http.request_completed
	http.queue_free()
	
	if error != OK:
		push_error("Error could not download game data: ", error_string(error))


## Uses the Internet to update the games library
func check_for_updates() -> void:
	# Download games data
	SettingsManager.ui_manager.loading_screen.show()
	
	await download_remote_library()
	SettingsManager.manager.get_library()
	SettingsManager.ui_manager.display_games_list()
	
	SettingsManager.ui_manager.loading_screen.hide()

extends Node

const GAME_DATA_URL := "https://dl.dropboxusercontent.com/scl/fi/9yorfq2zf93x3oly4uvfv/game_library.txt?rlkey=l2dzmtb4hnizbgzf302di0npv&st=8n2g08ky&dl=0"
var auto_check_updates := false

func _on_settings_loaded():
	if Updater.auto_check_updates:
		Updater.check_for_updates()

## Downloads the game data from the internet
func download_game_data() -> void:
	# Create http request
	var http := HTTPRequest.new()
	add_child(http)
	
	# Request data and save to file
	http.download_file = SettingsManager.GAME_LIBRARY_PATH
	var error := http.request(GAME_DATA_URL)
	await http.request_completed
	
	if error != OK:
		push_error("Error could not download game data: ", error_string(error))


## Uses the Internet to update the games library
func check_for_updates() -> void:
	# Download games data
	SettingsManager.ui_manager.loading_screen.show()
	
	await download_game_data()
	SettingsManager.manager.get_library()
	SettingsManager.ui_manager.display_games_list()
	
	SettingsManager.ui_manager.loading_screen.hide()

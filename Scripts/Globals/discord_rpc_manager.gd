extends Node

var rich_presence_enabled := false

func _ready() -> void:
	DiscordRPC.app_id = 1266920850339139664
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	enter_library()


func set_rich_presence(value: bool) -> void:
	rich_presence_enabled = value
	if rich_presence_enabled:
		DiscordRPC.unclear()
	else:
		DiscordRPC.clear()


func enter_game(game: GameData) -> void:
	if rich_presence_enabled:
		DiscordRPC.details = "Playing " + game.game_name
		DiscordRPC.large_image = game.icon_url
		DiscordRPC.large_image_text = game.game_name
		DiscordRPC.small_image = "logo"
		
		DiscordRPC.refresh()


func enter_library() -> void:
	if rich_presence_enabled:
		DiscordRPC.details = "Browsing Games"
		DiscordRPC.large_image = "logo"
		
		DiscordRPC.refresh()

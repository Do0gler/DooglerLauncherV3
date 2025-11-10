extends Node
class_name UIManager

@export var game_panel: PackedScene
@export var tag_panel: PackedScene
@export var screenshot_panel: PackedScene
@export var expandable_list: PackedScene

@onready var loading_screen: Control = %LoadingScreen
@onready var screenshot_popup = %ScreenshotViewer

var settings_popup: PopupMenu

func set_settings_state(settings_dict: Dictionary):
	settings_popup.set_item_checked(0, settings_dict.get("auto_check_updates", false))
	settings_popup.set_item_checked(1, settings_dict.get("rich_presence_enabled", false))


func display_games_list() -> void:
	var games_vbox: VBoxContainer = %GamesVBox
	# Clear previous games
	for child in games_vbox.get_children():
		child.queue_free()
	
	var organized_games := GameOrganizer.get_organized_games()
	
	for category in organized_games:
		var new_list: ExpandableList = expandable_list.instantiate()
		games_vbox.add_child(new_list)
		new_list.list_name = category
		for game: GameData in organized_games.get(category):
			var new_game_panel: GamePanel = game_panel.instantiate()
			new_game_panel.game_data = game
			new_game_panel.update_visuals()
			new_list.add_item(new_game_panel)
		new_list.call_deferred("update_visuals") # wait for list items to be positioned


func format_game_info(data_name: String, value: String) -> String:
	return "[color=gray]%-15s[/color] %s" % [data_name, value]


func display_game(game: GameData) -> void:
	%GameLogo.texture = game.icon
	%GameBackground.texture = game.background
	%GameNameLabel.text = game.game_name
	%PlaytimeLabel.text = GameData.secs_to_time_string(game.playtime_secs)
	%GameDescription.text = game.description
	%DateLabel.text = format_game_info("Date", game.creation_date)
	%EngineLabel.text = format_game_info("Engine", game.engine)
	%SizeLabel.text = format_game_info("File Size", str(game.file_size_mb) + "MB")
	%VersionLabel.text = format_game_info("Version", game.version_number)
	%FavoriteButton.set_pressed_no_signal(game.favorited)
	
	var tags_panel: GameInfoPanel = %TagsPanel
	var screenshots_panel: GameInfoPanel = %ScreenshotsPanel
	
	tags_panel.visible = not game.tags.is_empty()
	tags_panel.clear_items()
	for tag in game.tags:
		var new_tag: Tag = tag_panel.instantiate()
		new_tag.set_tag_name(tag)
		tags_panel.add_item(new_tag)
	
	screenshots_panel.visible = not game.screenshots.is_empty()
	screenshots_panel.clear_items()
	for screenshot in game.screenshots:
		var new_screenshot: Screenshot = screenshot_panel.instantiate()
		new_screenshot.set_screenshot(screenshot)
		new_screenshot.get_node("Button").pressed.connect(%ScreenshotViewer.open_screenshot.bind(screenshot))
		
		screenshots_panel.add_item(new_screenshot)

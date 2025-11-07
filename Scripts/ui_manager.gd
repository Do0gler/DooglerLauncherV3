extends Node
class_name UIManager

@export var game_panel: PackedScene
@export var tag_panel: PackedScene
@export var screenshot_panel: PackedScene

@onready var games_vbox: VBoxContainer = %GamesVBox
@onready var loading_screen: Control = %LoadingScreen

# Main game display elements
@onready var game_logo: TextureRect = %GameLogo
@onready var game_bg: TextureRect = %GameBackground
@onready var game_name_label: Label = %GameNameLabel
@onready var time_played_label: RichTextLabel = %PlaytimeLabel
@onready var game_description_label: Label = %GameDescription
@onready var game_date_label: RichTextLabel = %DateLabel
@onready var game_engine_label: RichTextLabel = %EngineLabel
@onready var game_size_label: RichTextLabel = %SizeLabel
@onready var game_version_label: RichTextLabel = %VersionLabel
@onready var tags_panel: GameInfoPanel = %TagsPanel
@onready var screenshots_panel: GameInfoPanel = %ScreenshotsPanel

var settings_popup: PopupMenu

func set_settings_state(settings_dict: Dictionary):
	settings_popup.set_item_checked(0, settings_dict.get("auto_check_updates", false))
	settings_popup.set_item_checked(1, settings_dict.get("rich_presence_enabled", false))


func display_games_list() -> void:
	# Clear previous games
	for child in games_vbox.get_children():
		child.queue_free()
	
	for game in SettingsManager.manager.games_library:
		var new_game_panel: GamePanel = game_panel.instantiate()
		new_game_panel.game_data = game
		new_game_panel.update_visuals()
		games_vbox.add_child(new_game_panel)


func format_game_info(data_name: String, value: String) -> String:
	return "[color=gray]%-15s[/color] %s" % [data_name, value]


func display_game(game: GameData) -> void:
	game_logo.texture = game.icon
	game_bg.texture = game.background
	game_name_label.text = game.game_name
	time_played_label.text = GameData.secs_to_time_string(game.playtime_secs)
	game_description_label.text = game.description
	game_date_label.text = format_game_info("Date", game.creation_date)
	game_engine_label.text = format_game_info("Engine", game.engine)
	game_size_label.text = format_game_info("File Size", str(game.file_size_mb) + "MB")
	game_version_label.text = format_game_info("Version", game.version_number)
	
	tags_panel.visible = !game.tags.is_empty()
	tags_panel.clear_items()
	for tag in game.tags:
		var new_tag: Tag = tag_panel.instantiate()
		new_tag.set_tag_name(tag)
		tags_panel.add_item(new_tag)
	
	screenshots_panel.visible = !game.screenshots.is_empty()
	screenshots_panel.clear_items()
	for screenshot in game.screenshots:
		var new_screenshot: Screenshot = screenshot_panel.instantiate()
		new_screenshot.set_screenshot(screenshot)
		screenshots_panel.add_item(new_screenshot)

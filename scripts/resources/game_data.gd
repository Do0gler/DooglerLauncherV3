class_name GameData
extends Resource

@export_category("Info")
@export var game_name: String
@export_multiline var description: String
@export var creation_date: String = "Unknown" #MM/DD/YYYY
@export_enum("Scratch", "Unity", "Godot") var engine: String = "Scratch"
@export var tags: Array[StringName]
@export var file_size_mb: float
@export_category("Download")
@export var download_path: String
@export var api_icon_name := "logo"
@export_category("Graphics")
@export var icon: Texture2D
@export var background: Texture2D
@export var screenshots: Array[Texture2D]
@export_category("Meta")
@export var version_number := "1.0"
@export var has_discord_rpc := false

var is_outdated := false

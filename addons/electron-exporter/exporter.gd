@tool
extends EditorExportPlugin

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int):
	# Get the directory where the export is happening
	var export_dir = path.get_base_dir()
	
	# Source file on your computer
	var source_file = "user://electron-runner/dist/GameRunner.exe"
	source_file = ProjectSettings.globalize_path(source_file)
	
	# Destination in the export
	var dest_file = export_dir.path_join("GameRunner.exe")
	
	# Copy the file
	var dir = DirAccess.open(export_dir)
	if dir:
		DirAccess.copy_absolute(source_file, dest_file)
		print("Copied electron app to: ", dest_file)

func _get_name() -> String:
	return "ElectronExporter"

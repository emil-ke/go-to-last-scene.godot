@tool
extends EditorPlugin

# settings
var shortcut_key = KEY_L
var shortcut_ctrl_pressed = true
var shortcut_shift_pressed = true
#

var shortcut: Shortcut

var current_scene_path: String = ""
var last_scene_path: String = ""


func _enter_tree() -> void:
	shortcut = Shortcut.new()
	var key_event = InputEventKey.new()
	key_event.keycode = shortcut_key
	key_event.ctrl_pressed = shortcut_ctrl_pressed
	key_event.shift_pressed = shortcut_shift_pressed
	key_event.command_or_control_autoremap = true
	shortcut.events = [key_event]

	# Connect early (even if there is no scene yet)
	if not scene_changed.is_connected(_on_scene_changed):
		scene_changed.connect(_on_scene_changed)

	# Initialize only if a scene is currently open
	var root: Node = EditorInterface.get_edited_scene_root()
	if root:
		current_scene_path = root.get_scene_file_path()
		last_scene_path = current_scene_path
	else:
		# No scene opened yet
		current_scene_path = ""
		last_scene_path = ""


func _unhandled_key_input(event: InputEvent) -> void:
	if shortcut.matches_event(event) and event.is_pressed():
		_go_to_last_scene()
		get_viewport().set_input_as_handled()


func _on_scene_changed(root: Node) -> void:
	var new_path: String = root.get_scene_file_path()

	if new_path == "" or new_path == current_scene_path:
		return

	if current_scene_path != "":
		last_scene_path = current_scene_path

	current_scene_path = new_path


func _go_to_last_scene() -> void:
	if last_scene_path == "" or last_scene_path == current_scene_path:
		return

	EditorInterface.open_scene_from_path(last_scene_path)

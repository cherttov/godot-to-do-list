@tool
extends EditorPlugin;

const SCENE_PATH: String = "res://addons/to-do-list/to-do-list.tscn";
var to_do_list: Control;


func _enter_tree() -> void:
	to_do_list = preload(SCENE_PATH).instantiate();
	EditorInterface.get_editor_main_screen().add_child(to_do_list);
	_make_visible(false);

func _exit_tree() -> void:
	if to_do_list:
		to_do_list.queue_free();

func _has_main_screen() -> bool:
	return true;

func _make_visible(visible: bool) -> void:
	if to_do_list:
		to_do_list.visible = visible;

func _get_plugin_name() -> String:
	return "ToDoList";

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons");

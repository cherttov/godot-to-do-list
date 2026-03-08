@tool
extends Control;

var task_scene: PackedScene = preload("res://addons/to-do-list/task/task.tscn");
var new_scene: PackedScene = preload("res://addons/to-do-list/task/new_task.tscn");

# Onready
func _ready():
	var editor: Object = EditorInterface;
	if Engine.is_editor_hint():
		load_tasks();
		_connect_all_tasks();
		_init_new_button();

# Connect tasks
func _connect_all_tasks() -> void:
	var container = $VBoxContainer;
	for task in container.get_children():
		if task.is_connected("edit_requested", _on_edit_requested):
			task.disconnect("edit_requested", _on_edit_requested);
		task.connect("edit_requested", _on_edit_requested);
		
		if task.is_connected("delete_requested", _on_delete_requested):
			task.disconnect("delete_requested", _on_delete_requested);
		task.connect("delete_requested", _on_delete_requested);
		
		if task.is_connected("checkbox_pressed", _on_checkbox_pressed):
			task.disconnect("checkbox_pressed", _on_checkbox_pressed);
		task.connect("checkbox_pressed", _on_checkbox_pressed);

# Connected edit signal
func _on_edit_requested(ref: Control) -> void:
	var dialog: AcceptDialog = AcceptDialog.new();
	add_child(dialog);
	
	dialog.title = "Edit Task Name";
	
	var input: LineEdit = LineEdit.new();
	input.text = ref.task_name;
	input.placeholder_text = "Enter new task name...";
	dialog.add_child(input);
	
	var save_changes: Callable = func(new_text: String):
		ref.task_name = new_text;
		ref.change_name(new_text);
		save_tasks();
		dialog.hide();
		dialog.queue_free();
	
	dialog.confirmed.connect(func(): save_changes.call(input.text));
	input.text_submitted.connect(save_changes);
	
	dialog.popup_centered(Vector2(300, 80));
	input.grab_focus();
	input.select_all();

# Connected delete signal
func _on_delete_requested(ref: Control) -> void:
	$VBoxContainer.remove_child(ref);
	ref.queue_free();
	save_tasks();

# Checkbox button
func _on_checkbox_pressed(status: bool) -> void:
	save_tasks();

# Initial new task button
func _init_new_button() -> void:
	# If already exists
	for child in $VBoxContainer.get_children():
		if child.has_signal("new_requested"):
			if !child.is_connected("new_requested", _on_new_requested):
				child.connect("new_requested", _on_new_requested);
			return;
	# If not (it shouldn't)
	var new_task_node = new_scene.instantiate();
	$VBoxContainer.add_child(new_task_node);
	new_task_node.owner = get_parent();
	new_task_node.connect("new_requested", _on_new_requested);

# Append new task button
func _append_new_button() -> void:
	for child in $VBoxContainer.get_children():
		if "new_requested" in child.get_signal_list().map(func(s): return s.name):
			$VBoxContainer.move_child(child, -1);
			break;

# Connected new signal
func _on_new_requested() -> void:
	var dialog: AcceptDialog = AcceptDialog.new();
	add_child(dialog);
	
	dialog.title = "New Task Name";
	
	var input: LineEdit = LineEdit.new();
	input.placeholder_text = "Enter new task name...";
	dialog.add_child(input);
	
	# Saving function
	var save_changes: Callable = func(new_text: String):
		var task_node = task_scene.instantiate();
		$VBoxContainer.add_child(task_node);
		task_node.task_name = new_text;
		task_node.change_name(new_text);
		task_node.owner = get_parent();
			
		task_node.connect("edit_requested", _on_edit_requested);
		task_node.connect("delete_requested", _on_delete_requested);
		task_node.connect("checkbox_pressed", _on_checkbox_pressed);
		_append_new_button();
		save_tasks();
		dialog.hide();
		dialog.queue_free();
	
	dialog.confirmed.connect(func(): save_changes.call(input.text));
	input.text_submitted.connect(save_changes);
	
	dialog.popup_centered(Vector2(300, 80));
	input.grab_focus();
	input.select_all();

# Saving data
func save_tasks() -> void:
	var data: TaskListData = TaskListData.new();
	
	for task in $VBoxContainer.get_children():
		if task.has_method("change_name") and not task.is_queued_for_deletion():
			var task_info: Dictionary[String, Variant] = {
				"name": task.task_name,
				"completed": task.get_node("%CheckBox").button_pressed
			}
			data.tasks.append(task_info);
	
	ResourceSaver.save(data, "res://to-do-list.tres");

# Loading data
func load_tasks() -> void:
	if FileAccess.file_exists("res://to-do-list.tres"):
		var data: TaskListData = load("res://to-do-list.tres");
		
		# Safe clear
		for task in $VBoxContainer.get_children():
			task.queue_free();
		
		for task in data.tasks:
			var task_node = task_scene.instantiate();
			$VBoxContainer.add_child(task_node);
			
			task_node.task_name = task["name"];
			task_node.change_name(task["name"]);
			task_node.get_node("%CheckBox").button_pressed = task["completed"];
			task_node.owner = get_parent();

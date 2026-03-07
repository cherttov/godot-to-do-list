@tool
extends Control;

# Export variables
@export var task_name: String;

# Signals
signal edit_requested(ref: Control);
signal delete_requested(ref: Control);
signal checkbox_pressed(status: bool);

# Onready
func _ready() -> void:
	%TaskEdit.text = task_name;
	
	if !%TaskEdit.is_connected("pressed", _on_edit_pressed):
		%TaskEdit.connect("pressed", _on_edit_pressed);
	if !%TaskDelete.is_connected("pressed", _on_delete_pressed):
		%TaskDelete.connect("pressed", _on_delete_pressed);
	if !%CheckBox.is_connected("pressed", _on_checkbox_pressed):
		%CheckBox.connect("pressed", _on_checkbox_pressed);

# Label setter
func change_name(new_name: String) -> void:
	%TaskName.text = new_name;

# Check box pressed
func _on_checkbox_pressed() -> void:
	emit_signal("checkbox_pressed", %CheckBox.button_pressed);

# Edit button pressed
func _on_edit_pressed() -> void:
	emit_signal("edit_requested", self);

# Delete signal
func _on_delete_pressed() -> void:
	emit_signal("delete_requested", self);

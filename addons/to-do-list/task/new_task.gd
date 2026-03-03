@tool
extends Control;

# Signals
signal new_requested;

# Onready
func _ready() -> void:
	if !%NewButton.is_connected("pressed", _on_new_pressed):
		%NewButton.connect("pressed", _on_new_pressed);

# New task button pressed
func _on_new_pressed() -> void:
	emit_signal("new_requested");

extends GoapAgent


@export var enable_debug_window: bool
@export var debug_window: Window


func toggle_debug_window(enabled: bool) -> void:
	debug_window.visible = enabled
	debug_window.set_process_mode(ProcessMode.PROCESS_MODE_INHERIT if enabled else ProcessMode.PROCESS_MODE_DISABLED)

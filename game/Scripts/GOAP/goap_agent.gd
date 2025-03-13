extends GoapAgent


@export var enable_debug_window: bool
@export var debug_window: Window


func activate_debug_window() -> void:
	debug_window.visible = enable_debug_window
	debug_window.set_process_mode(ProcessMode.PROCESS_MODE_INHERIT if enable_debug_window else ProcessMode.PROCESS_MODE_DISABLED)

extends Node2D


@onready var stats: RichTextLabel = $Control/Background/Stats
@onready var close_button: Button = $Control/Background/CloseButton


func _ready() -> void:
	game_manager.return_to_hub.connect(_do_mission_report)


func _do_mission_report() -> void:
	var sword_used_amount: String = "0"
	var shield_used_amount: String = "0"
	var bow_used_amount: String = "0"
	var enemies_killed: String = "0"
	var enemies_alive: String = "0"
	var npc_name: String = "None"
	
	if Blackboard.get_data("sword_used_amount"):
		sword_used_amount = str(Blackboard.get_data("sword_used_amount"))
	if Blackboard.get_data("shield_used_amount"):
		shield_used_amount = str(Blackboard.get_data("shield_used_amount"))
	if Blackboard.get_data("bow_used_amount"):
		bow_used_amount = str(Blackboard.get_data("bow_used_amount"))
	if Blackboard.get_data("enemies_killed"):
		enemies_killed = str(Blackboard.get_data("enemies_killed"))
	if Blackboard.get_data("enemies_alive"):
		enemies_alive = str(Blackboard.get_data("enemies_alive"))
	if is_instance_valid(Blackboard.get_data("npc")):
		npc_name = (Blackboard.get_data("npc") as Npc).display_name
	
	stats.text = \
"Sword used " + sword_used_amount + " amount
Shield used " + shield_used_amount + " amount
Bow used " + bow_used_amount + " amount
Fiends slain " + enemies_killed + "
Fiends left alive " + enemies_alive + "
Companion taken: " + npc_name
	visible = true


func _on_close_button_button_down():
	visible = false

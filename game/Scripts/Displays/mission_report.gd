class_name MissionReport
extends Node2D


@onready var stats: RichTextLabel = $Control/Background/Stats
@onready var close_button: Button = $Control/Background/CloseButton


func do_mission_report() -> void:
	visible = true
	
	if !Blackboard.get_data("mission_success"):
		stats.text = "Mission failed! 
No stats changed, but
if you fail again you'll be
fired and sent to hell."
		return
	
	var playstyle = UtilitySystem.get_last_playstyle()
	var data
	
	data = Blackboard.get_data("sword_used_amount")
	var sword_used_amount: String = str(data) if data else "0"
	
	data = Blackboard.get_data("shield_used_amount")
	var shield_used_amount: String = str(data) if data else "0"
	
	data = Blackboard.get_data("bow_used_amount")
	var bow_used_amount: String = str(data) if data else "0"
	
	data = Blackboard.get_data("enemies_killed")
	var enemies_killed: int = data if data else "0"
	
	data = Blackboard.get_data("enemies_total")
	var enemies_alive: int = data - enemies_killed if data else "0"
	
	data = Blackboard.get_data("npc_choices")
	var npc_name: String = (data as Array)[-1] if data else "None"
	
	data = Blackboard.get_data("npc_level_report")
	var npc_level: String = str(data) if data else "0/3"
	
	data = Blackboard.get_data("sword_level_report")
	var sword_level: String = str(data) if data else "0/3"
	
	data = Blackboard.get_data("shield_level_report")
	var shield_level: String = str(data) if data else "0/3"
	
	data = Blackboard.get_data("bow_level_report")
	var bow_level: String = str(data) if data else "0/3"
	
	stats.text = \
"Playstyle: " + playstyle + "
Sword used: " + sword_used_amount + " times
Shield used: " + shield_used_amount + " times
Bow used: " + bow_used_amount + " times
Enemies slain: " + str(enemies_killed) + "
Enemies left alive: " + str(enemies_alive) + "
Companion taken: " + npc_name + "
Companion level: " + npc_level + "
Sword level: " + sword_level + "
Shield level: " + shield_level + "
Bow level: " + bow_level


func _on_close_button_button_down():
	visible = false

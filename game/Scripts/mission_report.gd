class_name MissionReport
extends Node2D


@onready var stats: RichTextLabel = $Control/Background/Stats
@onready var close_button: Button = $Control/Background/CloseButton


func do_mission_report() -> void:
	var data = Blackboard.get_data("sword_used_amount")
	var sword_used_amount: String = str(data) if data else "0"
	
	data = Blackboard.get_data("shield_used_amount")
	var shield_used_amount: String = str(data) if data else "0"
	
	data = Blackboard.get_data("bow_used_amount")
	var bow_used_amount: String = str(data) if data else "0"
	
	data = Blackboard.get_data("enemies_killed")
	var enemies_killed: String = str(data) if data else "0"
	
	data = Blackboard.get_data("enemies_alive")
	var enemies_alive: String = str(data) if data else "0"
	
	data = Blackboard.get_data("npc_choices")
	var npc_name: String = (data as Array)[-1] if data else "None"
	
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

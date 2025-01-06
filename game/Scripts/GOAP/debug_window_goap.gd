extends Window

@onready var _blackboard_list: VBoxContainer = $CanvasLayer/HBoxContainer/Blackboard_list
@onready var _goal_list: VBoxContainer = $CanvasLayer/HBoxContainer/Goap_list
@onready var _action_plan: VBoxContainer = $CanvasLayer/HBoxContainer/Action_plan_list

@export var _goap_agent: GoapAgent

@export var font_size: int = 20

func _ready() -> void:
	# Populate goals list
	var goals: Array[GoapGoal] = _goap_agent.get_goals()
	
	# sort goals
	if !goals.is_empty():
		goals.sort_custom(goal_array_sort)
		
		for goal:GoapGoal in goals:
			var new_goal = Label.new()
			new_goal.text = goal.get_goal_name()
			new_goal.add_theme_font_size_override("font_size", font_size) 
			_goal_list.add_child(new_goal)


func _process(_delta: float) -> void:
	# clear window
	var child_list = []
	child_list.append(_blackboard_list.get_children())
	child_list.append(_action_plan.get_children())
	for child_array in child_list:
		for child in child_array:
			child.queue_free()
	
	var current_goal = _goap_agent.get_current_goal_name()
	var plan = _goap_agent.get_current_plan_actions()
	var plan_index = _goap_agent.Get_current_plan_index()
	
	# Populate blackboard list
	var blackboard_keys: Array[String] = [
		"damage_done",
		"amount_blocked",
		"enemies_alive",
		"sword_used_amount",
		"shield_used_amount",
		"bow_used_amount"
	]
	for key in blackboard_keys:
		if Blackboard.get_data(key):
			var data = Blackboard.get_data(key)
			var new_label = Label.new()
			new_label.text = key + "	-	%d" % data
			new_label.add_theme_font_size_override("font_size", font_size) 
			_blackboard_list.add_child(new_label)
	
	# Color goal list
	var current_goal_found = false
	for goal in _goal_list.get_children():
		if goal.text == current_goal:
			goal.set("theme_override_colors/font_color", Color.BLUE)
			current_goal_found = true
		elif !current_goal_found:
			goal.set("theme_override_colors/font_color", Color.GREEN)
		else:
			goal.set("theme_override_colors/font_color", Color.RED)
	
	# Populate action plan List
	for i in range(0, plan.size()):
		var new_label = Label.new()
		new_label.text = plan[i]
		if i <= plan_index:
			new_label.set("theme_override_colors/font_color", Color.GREEN)
		elif i == plan_index:
			new_label.set("theme_override_colors/font_color", Color.BLUE)
		else:
			new_label.set("theme_override_colors/font_color", Color.RED)
		new_label.add_theme_font_size_override("font_size", font_size) 
		_action_plan.add_child(new_label)
	

func goal_array_sort(a, b):
	return a.get_priority() > b.get_priority()

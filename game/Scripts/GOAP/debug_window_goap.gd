extends Window

@export var _blackboard_list: VBoxContainer
@export var _goal_list: VBoxContainer
@export var _action_plan: VBoxContainer 

@export var _goap_agent: GoapAgent

@export var font_size: int = 20

var current_displayed_goal: String
var goals: Array[GoapGoal]

func _ready() -> void:
	# Populate goals list
	goals = _goap_agent.get_goals()
	sort_goals()
	

func _process(_delta: float) -> void:
	# Get current data
	var current_goal = _goap_agent.get_current_goal_name()
	var plan = _goap_agent.get_current_plan_actions()
	var plan_index = _goap_agent.Get_current_plan_index()
	
	# Add blackboard values
	var blackboard_keys = Blackboard.get_keys()
	clear_container(_blackboard_list)
	for i in range(0, blackboard_keys.size()):
		if Blackboard.get_data(blackboard_keys[i]):
			var data = Blackboard.get_data(blackboard_keys[i])
			var new_label = Label.new()
			new_label.text = blackboard_keys[i].replace("_", " ") + "   -   %s" % str(data)
			new_label.add_theme_font_size_override("font_size", font_size * 0.5)
			new_label.size_flags_vertical = Control.SIZE_FILL
			new_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			_blackboard_list.add_child(new_label)		
	

	# Check if changes in Goap
	if current_goal != current_displayed_goal:
		current_displayed_goal = current_goal
		clear_container(_goal_list)
		sort_goals()
		
		# Color goal list
		var current_goal_found: bool = false
		for goal in _goal_list.get_children():
			if goal.text == current_goal:
				goal.set("theme_override_colors/font_color", Color.CYAN)
				current_goal_found = true
			elif !current_goal_found:
				goal.set("theme_override_colors/font_color", Color.GREEN)
			else:
				goal.set("theme_override_colors/font_color", Color.RED)
		
		# Populate action plan List
		for i in range(0, plan.size()):
			clear_container(_action_plan)
			var new_label = Label.new()
			new_label.text = plan[i].replace("_", " ")
			if i <= plan_index:
				new_label.set("theme_override_colors/font_color", Color.GREEN)
			elif i == plan_index:
				new_label.set("theme_override_colors/font_color", Color.CYAN)
			else:
				new_label.set("theme_override_colors/font_color", Color.RED)
			new_label.add_theme_font_size_override("font_size", font_size) 
			_action_plan.add_child(new_label)
	

func clear_container(container: Container):
	var child_list = []
	child_list.append(container.get_children())
	for child_array in child_list:
		for child in child_array:
			child.free()

func sort_goals():
	if !goals.is_empty():		
		goals.sort_custom(goal_array_sort)
		for goal:GoapGoal in goals:
			var new_goal = Label.new()
			new_goal.text = goal.get_goal_name().replace("_", " ")
			new_goal.add_theme_font_size_override("font_size", font_size) 
			_goal_list.add_child(new_goal)

func goal_array_sort(a, b):
	return a.get_priority() > b.get_priority()

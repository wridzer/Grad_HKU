#include "goap_agent.h"

#include <core/ai/blackboard.h>

GoapAgent::GoapAgent() {
	current_goal = nullptr;
}

GoapAgent::~GoapAgent() {}

void GoapAgent::set_goals(TypedArray<GoapGoal> p_goals) {
	GLTFTemplateConvert::set_from_array(goals, p_goals);
}

void GoapAgent::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_goals", "goal"), &GoapAgent::set_goals);
	ClassDB::bind_method(D_METHOD("get_goals"), &GoapAgent::get_goals);
	ClassDB::bind_method(D_METHOD("execute", "delta", "goap"), &GoapAgent::execute);
	ClassDB::bind_method(D_METHOD("physics_update", "delta", "actor"), &GoapAgent::physics_update);
	ClassDB::bind_method(D_METHOD("get_current_goal_name"), &GoapAgent::get_current_goal_name);
	ClassDB::bind_method(D_METHOD("get_current_plan_actions"), &GoapAgent::get_current_plan_actions);
	ClassDB::bind_method(D_METHOD("Get_current_plan_index"), &GoapAgent::Get_current_plan_index);

	ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "goals", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_INTERNAL | PROPERTY_USAGE_EDITOR), "set_goals", "get_goals");
}

void GoapAgent::execute(float delta, Node* actor, Goap *goap) {
	if (actor == nullptr)
		return;

	// debug names
	for (auto goal : goals) {
		if (goal != nullptr)
			goal->get_goal_name();
	}

	GoapGoal* goal = *get_best_goal();

	if (current_goal == nullptr || goal != current_goal) {
		if (goal == nullptr)
			return;

		current_goal = goal;
		current_plan = goap->get_plan(current_goal);
		current_plan_index = 0;

		print_line("Goal: ", goal->get_goal_name(), " - Priority: ", goal->get_priority());
		print_line("Plan:  - amount of actions: ", current_plan.actions.size(), " - costs: ", current_plan.cost);
		for ( auto action : current_plan.actions) {
			if (action != nullptr)
				print_line("Action: ", action->get_action_name(), " - Cost: ", action->get_cost());
			else
				print_line("Invalid action");
		}
	}

	follow_plan(current_plan, delta, actor);
}

void GoapAgent::physics_update(float delta, Node *actor) {
	if (actor == nullptr)
		return;

	if (current_plan.actions.size() == 0)
		return;

	int is_step_complete = current_plan.actions[current_plan_index]->perform_physics(actor, delta);
	if (is_step_complete and current_plan_index < current_plan.actions.size() - 1)
		current_plan_index += 1;
}

String GoapAgent::get_current_goal_name() {
		if (current_goal != nullptr)
			return current_goal->get_goal_name();
		else
			return "";
}

Vector<String> GoapAgent::get_current_plan_actions() {
	Vector<String> actions;
	for (auto action : current_plan.actions) {
		actions.push_back(action->get_action_name());
	}
	return actions;
}

Ref<GoapGoal> GoapAgent::get_best_goal() {
	Ref<GoapGoal> highest_priority;

	for (auto goal : goals) {
		if (!goal->is_goal_met() && (highest_priority == nullptr || goal->get_priority() > highest_priority->get_priority()))
			highest_priority = goal;
	}

	return highest_priority;
}

void GoapAgent::follow_plan(Plan plan, float delta, Node* actor) {
	if (plan.actions.size() == 0)
		return;

	bool is_step_complete = plan.actions[current_plan_index]->perform(actor, delta);
	if (is_step_complete){
		current_plan_index += 1;
		if (current_plan_index >= plan.actions.size())
			current_plan_index = 0;
	}
}

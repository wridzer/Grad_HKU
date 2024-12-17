#include "goap_goal.h"

GoapGoal::GoapGoal() {
}

GoapGoal::~GoapGoal() {
}

StringName GoapGoal::get_goal_name() {
	StringName goal_name = "";
	GDVIRTUAL_CALL(_get_goal_name, goal_name);
	name = goal_name;
	return goal_name;
}

bool GoapGoal::is_goal_met() {
	bool goal_met = false;
	GDVIRTUAL_CALL(_is_goal_met, goal_met);
	return goal_met;
}

int GoapGoal::get_priority() {
	int priority = 0;
	GDVIRTUAL_CALL(_get_priority, priority);
	return priority;
}

Dictionary GoapGoal::get_desired_state() {
	Dictionary desired_state;
	GDVIRTUAL_CALL(_get_desired_state, desired_state);
	return desired_state;
}

void GoapGoal::_bind_methods() {

}

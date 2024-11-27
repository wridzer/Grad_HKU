#include "goap_goal.h"

GoapGoal::GoapGoal() {
}

GoapGoal::~GoapGoal() {
}

bool GoapGoal::is_goal_met() {
	return false;
}

int GoapGoal::get_priority() {
	return 0;
}

Dictionary GoapGoal::get_desired_state() {
	return Dictionary();
}

void GoapGoal::_bind_methods() {
}

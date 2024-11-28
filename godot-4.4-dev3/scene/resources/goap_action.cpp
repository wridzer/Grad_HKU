#include "goap_action.h"

GoapAction::GoapAction() {
}

GoapAction::~GoapAction() {
}

bool GoapAction::are_preconditions_met() {
	return false;
}

void GoapAction::apply_effects() {
}

StringName GoapAction::get_action_name() {
	StringName action_name = "";
	GDVIRTUAL_CALL(_get_action_name, action_name);
	return action_name;
}

Dictionary GoapAction::get_preconditions() {
	return Dictionary();
}

Dictionary GoapAction::get_effects() {
	return Dictionary();
}

int GoapAction::get_cost() {
	return 0;
}

bool GoapAction::is_valid() {
	return false;
}

bool GoapAction::perform(Node* _actor, float _delta) {
	return false;
}

void GoapAction::_bind_methods() {
}

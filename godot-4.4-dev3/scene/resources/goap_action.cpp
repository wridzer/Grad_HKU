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
	name = action_name;
	return action_name;
}

Dictionary GoapAction::get_preconditions() {
	Dictionary preconditions;
	GDVIRTUAL_CALL(_get_preconditions, preconditions);
	return preconditions;
}

Dictionary GoapAction::get_effects() {
	Dictionary effects;
	GDVIRTUAL_CALL(_get_effects, effects);
	return effects;
}

int GoapAction::get_cost() {
	int cost = 0;
	GDVIRTUAL_CALL(_get_cost, cost);
	return cost;
}

bool GoapAction::is_valid() {
	bool valid = false;
	GDVIRTUAL_CALL(_is_valid, valid);
	return valid;
}

bool GoapAction::perform(Node* _actor, float _delta) {
	bool success = false;
	GDVIRTUAL_CALL(_perform, _actor, _delta, success);
	return success;
}

bool GoapAction::perform_physics(Node *_actor, float _delta) {
	bool success = false;
	GDVIRTUAL_CALL(_perform_physics, _actor, _delta, success);
	return success;
}

void GoapAction::_bind_methods() {
}

#include "goap.h"

#include <core/ai/blackboard.h>

Goap::Goap() {
}

Goap::~Goap() {
}

void Goap::set_actions(TypedArray<GoapAction> p_actions) {
	GLTFTemplateConvert::set_from_array(actions, p_actions);
}

void Goap::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_actions", "action"), &Goap::set_actions);
	ClassDB::bind_method(D_METHOD("get_actions"), &Goap::get_actions);
	//ClassDB::bind_method(D_METHOD("get_plan", "goal"), &Goap::get_plan);

	//ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "goals", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_INTERNAL | PROPERTY_USAGE_EDITOR), "set_goals", "get_goals");
	ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "actions", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_INTERNAL | PROPERTY_USAGE_EDITOR), "set_actions", "get_actions");
}

Plan Goap::get_plan(Ref<GoapGoal> goal) {
	//debug names
	for (auto action : actions) {
		action->get_action_name();
	}

	Dictionary desired_state = goal->get_desired_state().duplicate();
	if (desired_state.is_empty()) {
		return Plan();
	}

	Vector<Plan> plans = _find_best_plan(goal, desired_state);
	Plan cheapest_plan = _get_cheapest_plan(plans);

	return cheapest_plan;
}

Vector<Plan> Goap::_find_best_plan(Ref<GoapGoal> goal, const Dictionary &desired_state) {
	PlanTree root_plan{ goal, desired_state, {} };

	Vector<Plan> plans;
	if (_build_plans(root_plan, desired_state)) {
		plans = _transform_tree_into_plans(root_plan);
	}
	return plans;
}

Plan Goap::_get_cheapest_plan(const Vector<Plan> &plans) {
	Plan best_plan;
	best_plan.cost = std::numeric_limits<real_t>::max();

	for (const auto &plan : plans) {
		if (plan.cost < best_plan.cost) {
			best_plan = plan;
		}
	}
	return best_plan;
}

bool Goap::_build_plans(PlanTree &current_plan, const Dictionary &desired_state) {
	bool has_followup = false;
	Dictionary state = desired_state.duplicate();

	for (int i = 0; i < actions.size(); i++) {
		Ref<GoapAction> action = actions[i];
		if (!action->is_valid()) {
			continue;
		}

		bool should_use_action = false;
		Dictionary effects = action->get_effects();
		Dictionary new_desired_state = state.duplicate();

		for (const Variant &s : new_desired_state.keys()) {
			if (new_desired_state[s] == effects[s]) {
				new_desired_state.erase(s);
				should_use_action = true;
			}
		}

		if (should_use_action) {
			Dictionary preconditions = action->get_preconditions();
			for (const Variant &p : preconditions.keys()) {
				new_desired_state[p] = preconditions[p];
			}

			PlanTree new_plan{ action, state, {} };

			if (new_desired_state.is_empty() || _build_plans(new_plan, new_desired_state)) {
				current_plan.children.push_back(new_plan);
				has_followup = true;
			}
		}
	}
	return has_followup;
}

Vector<Plan> Goap::_transform_tree_into_plans(const PlanTree &root_plan) {
	Vector<Plan> plans;

	if (root_plan.children.is_empty()) {
		Plan plan;
		plan.actions.push_back(root_plan.action);
		plan.cost = root_plan.action->get_cost();
		plans.push_back(plan);
		return plans;
	}

	for (int i = 0; i < root_plan.children.size(); i++) {
		Vector<Plan> child_plans = _transform_tree_into_plans(root_plan.children[i]);
		for (int j = 0; j < child_plans.size(); j++) {
			Plan plan = child_plans[j];
			if (root_plan.action != nullptr) {
				plan.actions.push_back(root_plan.action);
				plan.cost += root_plan.action->get_cost();
			}
			plans.push_back(plan);
		}
	}

	return plans;
}

void Goap::_print_plan(const Plan &plan) {
	String action_names;
	for (int i = 0; i < plan.actions.size(); i++) {
		// Cast the Variant to a Ref<GoapAction>
		Ref<GoapAction> action = plan.actions[i];
		if (action.is_valid()) {
			action_names += action->get_class_name();
			action_names += " ";
		}
	}
	printf("Plan cost: %f, actions: %s\n", plan.cost, action_names.utf8().get_data());
}

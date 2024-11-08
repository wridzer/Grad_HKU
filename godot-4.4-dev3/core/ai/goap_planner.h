#pragma once

#include <array>
#include <core/io/resource.h>

class GoapPlanner : public Resource {
	GDCLASS(GoapPlanner, Resource);

public:
	void _init();
	void register_classes();
	GoapPlanner();
	~GoapPlanner();

	//Array plan(const Dictionary &currentState, const Ref<Goal> &goal, const Array &actions) {
	//	Array actionPlan;
	//	Dictionary state = currentState;

	//	while (!goal->is_achieved(state)) {
	//		bool actionFound = false;

	//		for (int i = 0; i < actions.size(); ++i) {
	//			Ref<Action> action = actions[i];

	//			if (action->is_achievable(state)) {
	//				action->apply_effects(state);
	//				actionPlan.append(action);
	//				actionFound = true;
	//				break;
	//			}
	//		}

	//		if (!actionFound) {
	//			printf("No feasible action found to reach the goal!");
	//			return Array(); // Return an empty plan if no actions can be taken
	//		}
	//	}

	//	return actionPlan;
	//}
};

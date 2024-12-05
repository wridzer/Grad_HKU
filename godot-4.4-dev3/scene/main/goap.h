#pragma once

#include <core/object/class_db.h>
#include <core/variant/array.h>
#include <modules/gltf/gltf_template_convert.h>
#include <scene/main/node.h>
#include <scene/resources/goap_action.h>
#include <scene/resources/goap_goal.h>

struct Plan {
	Vector<Ref<GoapAction>> actions;
	real_t cost;

	Plan() :
			cost(0) {}
	Plan(Vector<Ref<GoapAction>> actions, real_t cost) :
			actions(actions), cost(cost) {}
};

class Goap : public Node {
	GDCLASS(Goap, Node);

private:
	Vector<Ref<GoapAction>> actions;

public:

	Goap();
	~Goap();

	void set_actions(TypedArray<GoapAction> p_actions);
	TypedArray<GoapAction> get_actions() const { return GLTFTemplateConvert::to_array(actions); }

	Plan get_plan(Ref<GoapGoal> goal);

private:
	Vector<Plan> _find_best_plan(Ref<GoapGoal> goal, const Dictionary &desired_state);
	Plan _get_cheapest_plan(const Vector<Plan> &plans);
	bool _build_plans(Plan &current_plan, const Dictionary &desired_state);
	Vector<Plan> _transform_tree_into_plans(const Plan &root_plan);
	void _print_plan(const Plan &plan);

protected:
	static void _bind_methods();
};
#pragma once

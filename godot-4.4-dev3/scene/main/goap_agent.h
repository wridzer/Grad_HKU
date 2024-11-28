#pragma once

#include <core/object/class_db.h>
#include <core/variant/array.h>
#include <modules/gltf/gltf_template_convert.h>
#include <scene/main/node.h>
#include <scene/resources/goap_action.h>
#include <scene/resources/goap_goal.h>
#include <core/ai/goap_planner.h>

class GoapAgent : public Node {
	GDCLASS(GoapAgent, Node);

private:
	Vector<Ref<GoapGoal>> goals;
	GoapGoal *current_goal;
	Plan current_plan;
	int current_plan_index = 0;

	Node *actor;

public:
	GoapAgent();
	~GoapAgent();

	void set_goals(TypedArray<GoapGoal> p_goals);
	TypedArray<GoapGoal> get_goals() const { return GLTFTemplateConvert::to_array(goals); }

private:
	virtual void _process(float delta);
	Ref<GoapGoal> get_best_goal();
	void follow_plan(Plan plan, float delta);

protected:
	static void _bind_methods();
};

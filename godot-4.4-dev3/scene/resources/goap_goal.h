#pragma once

#include <core/io/resource.h>

class GoapGoal : public Resource {
	GDCLASS(GoapGoal, Resource);

public:
	GoapGoal();
	~GoapGoal();

	StringName name;

	virtual StringName get_goal_name();
	virtual bool is_goal_met();
	virtual int get_priority();

	virtual Dictionary get_desired_state();


protected:
	static void _bind_methods();

	GDVIRTUAL0RC(StringName, _get_goal_name)
	GDVIRTUAL0RC(bool, _is_goal_met)
	GDVIRTUAL0RC(int, _get_priority);
	GDVIRTUAL0RC(Dictionary, _get_desired_state);
};

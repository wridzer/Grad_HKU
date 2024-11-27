#pragma once

#include <core/io/resource.h>

class GoapGoal : public Resource {
	GDCLASS(GoapGoal, Resource);

public:
	GoapGoal();
	~GoapGoal();

	virtual bool is_goal_met();
	virtual int get_priority();

	virtual Dictionary get_desired_state();


protected:
	static void _bind_methods();
};

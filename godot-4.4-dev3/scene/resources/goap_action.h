#ifndef GOAP_ACTION
#define GOAP_ACTION

#include <core/io/resource.h>

class GoapAction : public Resource {
	GDCLASS(GoapAction, Resource);

public:
	GoapAction();
	~GoapAction();

	virtual bool are_preconditions_met();
	virtual void apply_effects();

	virtual StringName get_action_name();
	virtual Dictionary get_preconditions();
	virtual Dictionary get_effects();
	virtual int get_cost();

	virtual bool is_valid();

	bool perform(Node* _actor, float _delta);

protected:
	static void _bind_methods();

	GDVIRTUAL1(_get_action_name, StringName)
	GDVIRTUAL1(_get_preconditions, Dictionary)
	GDVIRTUAL1(_get_effects, Dictionary)
};
#endif // !GOAP_ACTION

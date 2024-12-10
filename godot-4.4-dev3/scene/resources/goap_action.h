#ifndef GOAP_ACTION
#define GOAP_ACTION

#include <core/io/resource.h>
#include <scene/main/node.h>

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
	bool perform_physics(Node *_actor, float _delta);

protected:
	static void _bind_methods();

	GDVIRTUAL0RC(StringName, _get_action_name)
	GDVIRTUAL0RC(Dictionary, _get_preconditions)
	GDVIRTUAL0RC(Dictionary, _get_effects)
	GDVIRTUAL0RC(int, _get_cost);
	GDVIRTUAL0RC(bool, _is_valid);
	GDVIRTUAL2RC(bool, _perform, Node*, float);
	GDVIRTUAL2RC(bool, _perform_physics, Node *, float);
};
#endif // !GOAP_ACTION

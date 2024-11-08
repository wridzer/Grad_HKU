#ifndef GOAP_ACTION
#define GOAP_ACTION

#include <scene/main/node.h>
class GoapAction : public Node {
	GDCLASS(GoapAction, Node);

public:
	// Constructor
	GoapAction() {}

	// Destructor
	~GoapAction() {}

	// Precondition
	virtual bool is_precondition_satisfied(const Dictionary &p_world_state) const = 0;

	// Effects
	virtual Dictionary apply_effects(const Dictionary &p_world_state) const = 0;

	// Cost
	virtual int get_cost() const = 0;

	// Name
	virtual String get_name() const = 0;

	// Action
	virtual void execute() = 0;
};
#endif // !GOAP_ACTION

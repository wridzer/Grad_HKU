#include "goap_planner.h"

void GoapPlanner::register_classes() {
	//ClassDB::register_class<GoapAction>();

	//ClassDB::register_class<Action>();
	//ClassDB::register_class<Goal>();
	//ClassDB::register_class<Planner>();
}

// In your module initialization function
GoapPlanner::GoapPlanner() {
	register_classes();
}

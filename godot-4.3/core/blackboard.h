#ifndef BLACKBOARD
#define BLACKBOARD

#include "core/object/class_db.h"
#include "core/object/object.h"
#include "core/templates/hash_map.h"

template <typename T>
class TypedArray;

class Blackboard : public Object {
	GDCLASS(Blackboard, Object);

private:
	static Blackboard *singleton;

public:
	static _FORCE_INLINE_ Blackboard *get_singleton() { return singleton; }
	HashMap<String, Variant> blackboard_data;

	//get, add, clear and remove data from the blackboard
	Variant get_data(const String &p_key);
	List<StringName> get_keys();
	void add_data(const String &p_key, const Variant &p_data);
	void clear_data();
	void remove_data(const String &p_key);

	// save and load data from file using playerprefs
	void save_data();
	void load_data();

	Blackboard();
	~Blackboard();

protected:
	static void _bind_methods();

private:

};
#endif // !BLACKBOARD

#ifndef BLACKBOARD
#define BLACKBOARD

#include "core/object/class_db.h"
#include "core/object/object.h"
#include "core/templates/hash_map.h"

class Blackboard : public Object {
	GDCLASS(Blackboard, Object);

private:
	static Blackboard *singleton;

public:
	static _FORCE_INLINE_ Blackboard *get_singleton() { return singleton; }
	HashMap<String, Variant> blackboard_data;

	//get, add, clear and remove data from the blackboard
	Variant get_data(const String &p_key);
	TypedArray<String> get_keys() const;
	void add_data(const String &p_key, const Variant &p_data);
	void increment_data_int(const String &p_key, const int &p_data);
	void increment_data_float(const String &p_key, const float &p_data);
	void clear_utility_data(const Array &p_keys);
	void clear_data();
	void dump_data();
	void remove_data(const String &p_key);


	// save and load data from file using playerprefs
	void save_data();
	void load_data();

	Blackboard();
	~Blackboard();

protected:
	static void _bind_methods();


private:
	void save_to_csv(const String &p_path);
	int test_counter = 0;
};
#endif // !BLACKBOARD

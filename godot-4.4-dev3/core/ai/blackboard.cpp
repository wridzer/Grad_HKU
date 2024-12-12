#include "Blackboard.h"

#include "core/config/project_settings.h"
#include <scene/main/node.h>

Blackboard *Blackboard::singleton = nullptr;

Variant Blackboard::get_data(const String &p_key) {
	if (blackboard_data.has(p_key)) {
		return Variant(blackboard_data[p_key]);
	}
	return Variant();
}

List<StringName> Blackboard::get_keys() {
	List<StringName> keys;
	for (KeyValue<String, Variant> pair : blackboard_data) {
		keys.push_back(pair.key);
	}
	return keys;
}

void Blackboard::add_data(const String &p_key, const Variant &p_data) {
	blackboard_data[p_key] = p_data;
}

void Blackboard::clear_data() {
	blackboard_data.clear();
}

void Blackboard::remove_data(const String &p_key) {
	blackboard_data.erase(p_key);
}

void Blackboard::save_data() {
	for (const StringName &key : get_keys()) {
		// Save each blackboard variable to project settings
		ProjectSettings::get_singleton()->set("blackboard/" + key, blackboard_data[key]);
	}

	//ProjectSettings::get_singleton()->save(); // TODO (wkamphuis) - only do this on close
}

void Blackboard::load_data() {
	blackboard_data.clear();

	// Load blackboard variables from project settings
	List<PropertyInfo> props;
	ProjectSettings::get_singleton()->get_property_list(&props);

	for (const PropertyInfo &prop : props) {
		if (prop.name.begins_with("blackboard/")) {
			String key_name = prop.name.substr(String("blackboard/").size() - 1);
			blackboard_data[key_name] = ProjectSettings::get_singleton()->get(prop.name);
		}
	}
}

Blackboard::Blackboard() {
	ERR_FAIL_COND_MSG(singleton, "Singleton in Blackboard already exist.");
	singleton = this;
}

Blackboard::~Blackboard() {
	if (singleton == this) {
		save_data();

		// Ensure project settings are saved to disk
		if (!blackboard_data.is_empty())
			ProjectSettings::get_singleton()->save(); // only do this on close
	}
	singleton = nullptr;
}

void Blackboard::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_data", "key"), &Blackboard::get_data);
	//ClassDB::bind_method(D_METHOD("get_keys"), &Blackboard::get_keys);
	ClassDB::bind_method(D_METHOD("add_data", "key", "data"), &Blackboard::add_data);
	ClassDB::bind_method(D_METHOD("clear_data"), &Blackboard::clear_data);
	ClassDB::bind_method(D_METHOD("remove_data", "key"), &Blackboard::remove_data);
	ClassDB::bind_method(D_METHOD("save_data"), &Blackboard::save_data);
	ClassDB::bind_method(D_METHOD("load_data"), &Blackboard::load_data);
}

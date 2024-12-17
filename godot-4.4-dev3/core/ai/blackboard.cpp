#include "Blackboard.h"

#include "core/config/project_settings.h"
#include <scene/main/node.h>
#include "core/io/file_access.h"
#include <core/io/dir_access.h>

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

void Blackboard::increment_data_int(const String &p_key, const int &p_data) {
	if (blackboard_data.has(p_key)) {
		blackboard_data[p_key] = (int)blackboard_data[p_key] + p_data;
	} else {
		blackboard_data[p_key] = p_data;
	}
}

void Blackboard::increment_data_float(const String &p_key, const float &p_data) {
	if (blackboard_data.has(p_key)) {
		blackboard_data[p_key] = (float)blackboard_data[p_key] + p_data;
	} else {
		blackboard_data[p_key] = p_data;
	}
}

void Blackboard::clear_data() {
	blackboard_data.clear();
}

void Blackboard::dump_data()
{
	save_to_csv(ProjectSettings::get_singleton()->get_resource_path() + "/blackboard_dump/blackboard.csv");
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
	ClassDB::bind_method(D_METHOD("dump_data"), &Blackboard::dump_data);
	ClassDB::bind_method(D_METHOD("increment_data", "key", "data"), &Blackboard::increment_data_int);
	ClassDB::bind_method(D_METHOD("increment_data", "key", "data"), &Blackboard::increment_data_float);
}

void Blackboard::save_to_csv(const String &p_path) {
	String path = p_path.simplify_path();

	// Create dir if not exists
	Ref<DirAccess> dir = DirAccess::create(DirAccess::ACCESS_FILESYSTEM);
	if (!DirAccess::exists(path.get_base_dir())) {
		dir->make_dir_recursive(path.get_base_dir());
	}

	Ref<FileAccess> file = nullptr;

	if (FileAccess::exists(path)) {
		file = FileAccess::open(path, FileAccess::READ_WRITE);
	} else {
		// this fuckery is needed to create a file because FileAccess::WRITE creates a file but will truncate it
		// file FileAccess::READ_WRITE will not create it but will write without truncating
		file = FileAccess::open(path, FileAccess::WRITE); // Create file
	}

	// Add header if not exists
	Vector<String> keys;
	for (KeyValue<String, Variant> pair : blackboard_data) {
		keys.push_back(pair.key);
	}
	Vector<String> header = file->get_csv_line();

	if (header.is_empty() || header != keys) {
		file->store_csv_line(keys);
	}

	file = FileAccess::open(path, FileAccess::READ_WRITE); // Open file for writing without truncating
	file->seek_end(); // move cursor to end of file

	// Add data
	Vector<String> values;
	for (auto a : blackboard_data) {
		values.push_back(a.value.stringify());
	}
	file->store_csv_line(values);

	file->close();
}

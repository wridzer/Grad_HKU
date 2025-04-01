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

TypedArray<String> Blackboard::get_keys() const {
	TypedArray<String> keys;
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

void Blackboard::clear_utility_data(const Array &p_keys) {
	for (auto key : p_keys) {
		if (blackboard_data.has(key)){
			blackboard_data.erase(key);
		}
	}
}

void Blackboard::clear_data() {
	blackboard_data.clear();
}

void Blackboard::dump_data()
{
	OS* os = OS::get_singleton();

	String base;
	if (os->has_feature("editor")) {
		base = ProjectSettings::get_singleton()->get_resource_path();
	}
	else {
		base = os->get_executable_path().get_base_dir();
	}

	base += "/blackboard_dump/blackboard";
	int counter = 1;
	String extension = ".txt";
	String path = base + String::num(counter) + extension;

	while (FileAccess::exists(path)) {
		counter += 1;
		path = base + String::num(counter) + extension;
	}

	save_to_csv(path);
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
		//save_data();

		// Ensure project settings are saved to disk
		if (!blackboard_data.is_empty())
			ProjectSettings::get_singleton()->save(); // only do this on close
	}
	singleton = nullptr;
}

void Blackboard::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_data", "key"), &Blackboard::get_data);
	ClassDB::bind_method(D_METHOD("get_keys"), &Blackboard::get_keys);
	ClassDB::bind_method(D_METHOD("add_data", "key", "data"), &Blackboard::add_data);
	ClassDB::bind_method(D_METHOD("clear_data"), &Blackboard::clear_data);
	ClassDB::bind_method(D_METHOD("remove_data", "key"), &Blackboard::remove_data);
	ClassDB::bind_method(D_METHOD("save_data"), &Blackboard::save_data);
	ClassDB::bind_method(D_METHOD("load_data"), &Blackboard::load_data);
	ClassDB::bind_method(D_METHOD("dump_data"), &Blackboard::dump_data);
	ClassDB::bind_method(D_METHOD("increment_data", "key", "data"), &Blackboard::increment_data_int);
	ClassDB::bind_method(D_METHOD("increment_data", "key", "data"), &Blackboard::increment_data_float);
	ClassDB::bind_method(D_METHOD("clear_utility_data", "keys"), &Blackboard::clear_utility_data);
}

void Blackboard::save_to_csv(const String &p_path) {
	// Create dir if not exists
	Ref<DirAccess> dir = DirAccess::create(DirAccess::ACCESS_FILESYSTEM);
	if (!DirAccess::exists(p_path.get_base_dir())) {
		print_line(p_path.get_base_dir());
		dir->make_dir_recursive_absolute(p_path.get_base_dir());
	}

	// Create/Open file
	Ref<FileAccess> file = nullptr;
	Vector<String> header;

	if (FileAccess::exists(p_path)) {
		file = FileAccess::open(p_path, FileAccess::READ_WRITE);

		// Get header (adds empty entry if file is empty)
		header = file->get_csv_line();
	} else {
		// this fuckery is needed to create a file because FileAccess::WRITE creates a file but will truncate it
		// file FileAccess::READ_WRITE will not create it but will write without truncating
		file = FileAccess::open(p_path, FileAccess::WRITE); // Create file
		file = FileAccess::open(p_path, FileAccess::READ_WRITE); // Open file for writing without truncating
	}

	// Get data from blackboard and order it
	Vector<String> blackboard_data_headers = Vector<String>();
	for (auto &a : blackboard_data) {
		blackboard_data_headers.append(a.key);
	}
	blackboard_data_headers.sort();

	// Create vector for existing lines
	Vector<Vector<String>> existing_lines = Vector<Vector<String>>();
	bool end_of_file = false;
	while (!end_of_file) {
		int i = 0;
		Vector<String> line = file->get_csv_line();
		if (line[0].is_empty()) {
			end_of_file = true;
		} else {
			Vector<String> line_data = Vector<String>();
			for (auto &a : line) {
				line_data.append(a);
				i++;
			}
			existing_lines.append(line_data);
		}
	}

	// Add new header for current data and empty values for existing lines
	file = FileAccess::open(p_path, FileAccess::WRITE);

	if (header.is_empty()) {
		header = blackboard_data_headers;
	} else for (int i = 0; i < blackboard_data_headers.size(); i++) {
		if (blackboard_data_headers[i] != header[i]) {
			header.insert(i, blackboard_data_headers[i]);
			for (auto &a : existing_lines) {
				a.insert(i, "");
			}
		}
	}

	// Write header
	file->store_csv_line(header);

	// Add old data, then current data
	for (auto &a : existing_lines) {
		Vector<String> line = Vector<String>();
		for (auto &b : a) {
			line.push_back(b);
		}
		file->store_csv_line(line);
	}
	Vector<String> line = Vector<String>();
	for (auto &a : blackboard_data_headers) {
		line.push_back(get_data(a).stringify());
	}
	file->store_csv_line(line);

	file->close();
}

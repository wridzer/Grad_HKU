#include "goap_editor.h"

#include "editor/editor_settings.h"
#include "editor/editor_string_names.h"
#include "editor/event_listener_line_edit.h"
#include "editor/input_event_configuration_dialog.h"
#include "editor/themes/editor_scale.h"
#include "scene/gui/check_button.h"
#include "scene/gui/separator.h"
#include "scene/gui/tree.h"

GoapEditor::GoapEditor() {
	VBoxContainer *main_vbox = memnew(VBoxContainer);
	main_vbox->set_anchors_and_offsets_preset(PRESET_FULL_RECT);
	add_child(main_vbox);

	HBoxContainer *action_input_box = memnew(HBoxContainer);
	main_vbox->add_child(action_input_box);

	open_file_dialog_button = memnew(Button);
	open_file_dialog_button->set_text(TTR("Select GoapAction"));
	open_file_dialog_button->connect("pressed", callable_mp(this, &GoapEditor::_on_open_file_dialog_pressed));
	action_input_box->add_child(open_file_dialog_button);

	goap_tree = memnew(Tree);
	goap_tree->set_v_size_flags(Control::SIZE_EXPAND_FILL);
	goap_tree->set_columns(3);
	goap_tree->set_hide_root(true);
	goap_tree->set_column_titles_visible(true);
	goap_tree->set_column_title(0, TTR("Name"));
	goap_tree->set_column_title(1, TTR("Preconditions"));
	goap_tree->set_column_title(2, TTR("Effects"));
	main_vbox->add_child(goap_tree);

	file_dialog = memnew(EditorFileDialog);
	file_dialog->set_file_mode(EditorFileDialog::FILE_MODE_OPEN_FILE);
	file_dialog->add_filter("*.tres;*.res ; GoapAction Resources");
	file_dialog->connect("file_selected", callable_mp(this, &GoapEditor::_on_file_dialog_selected));
	add_child(file_dialog);
}

void GoapEditor::_on_open_file_dialog_pressed() {
	file_dialog->popup_centered_ratio();
}

void GoapEditor::_on_file_dialog_selected(const String &p_path) {
	Ref<GoapAction> action = ResourceLoader::load(p_path);
	if (action.is_valid()) {
		add_goap_action(action);
		print_line("Loaded GoapAction: " + action->get_action_name());
	} else {
		print_line("Failed to load GoapAction from path: " + p_path);
	}
}


void GoapEditor::add_goap_action(const Ref<GoapAction> &p_action) {
	goap_cache.push_back(p_action);
	_update_goap_tree();
}

void GoapEditor::update_goap_list(const TypedArray<GoapAction> &p_actions) {
	goap_cache = p_actions;
	_update_goap_tree();
}

void GoapEditor::_update_goap_tree() {
	print_line("Updating GOAP tree. Cached actions: " + itos(goap_cache.size()));

	goap_tree->clear();

	TreeItem *root = goap_tree->create_item();

	for (int i = 0; i < goap_cache.size(); i++) {
		Ref<GoapAction> goap_action = goap_cache[i];

		// Ensure the action is valid.
		if (!goap_action.is_valid()) {
			print_line("Invalid GoapAction in cache at index: " + itos(i)); // Debug line
			continue;
		}

		TreeItem *goap_item = goap_tree->create_item(root);

		goap_item->set_text(0, goap_action->get_action_name());
		goap_item->set_text(1, goap_action->get_preconditions().is_empty() ? "None" : goap_action->get_preconditions()[0]);
		goap_item->set_text(2, goap_action->get_effects().is_empty() ? "None" : goap_action->get_effects()[0]);

		goap_item->set_metadata(0, i); // Store index for reference
	}

	goap_tree->update_draw_order();
}


void GoapEditor::_bind_methods() {
	ClassDB::bind_method(D_METHOD("add_goap_action", "action"), &GoapEditor::add_goap_action);
	ClassDB::bind_method(D_METHOD("update_goap_list", "actions"), &GoapEditor::update_goap_list);
	ClassDB::bind_method(D_METHOD("_on_open_file_dialog_pressed"), &GoapEditor::_on_open_file_dialog_pressed);
	ClassDB::bind_method(D_METHOD("_on_file_dialog_selected", "path"), &GoapEditor::_on_file_dialog_selected);
}

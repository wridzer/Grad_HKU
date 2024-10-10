#include "editor/blackboard_editor.h"

#include "core/blackboard.h"
#include "editor/editor_settings.h"
#include "editor/editor_string_names.h"
#include "editor/event_listener_line_edit.h"
#include "editor/input_event_configuration_dialog.h"
#include "editor/themes/editor_scale.h"
#include "scene/gui/check_button.h"
#include "scene/gui/separator.h"
#include "scene/gui/tree.h"

void BlackboardEditor::_bind_methods() {
}

void BlackboardEditor::_action_edited() {
}

void BlackboardEditor::_tree_item_activated() {
}

void BlackboardEditor::_tree_button_pressed() {
}

void BlackboardEditor::_on_button_clicked() {
}

void BlackboardEditor::update_blackboard_list(const Vector<BlackboardInfo> &p_blackboard_infos) {
	if (!p_blackboard_infos.is_empty()) {
		blackboard_cache = p_blackboard_infos;
	}

	blackboard_tree->clear();
	TreeItem *root = blackboard_tree->create_item();

	// Setting up columns (ensure they match the layout of Project Settings)
	for (int i = 0; i < blackboard_cache.size(); i++) {
		BlackboardInfo blackboard_info = blackboard_cache[i];

		TreeItem *blackboard_item = blackboard_tree->create_item(root);
		ERR_FAIL_NULL(blackboard_item);

		blackboard_item->set_meta("__name", blackboard_info.name);
		blackboard_item->set_meta("__value", blackboard_info.data);
		blackboard_item->set_meta("__type", blackboard_info.type);

		// First Column - Name
		blackboard_item->set_text(0, blackboard_info.name);
		blackboard_tree->set_column_expand(0, true); // Let this column expand

		// Second Column - Value
		blackboard_item->set_text(1, blackboard_info.data);
		blackboard_tree->set_column_expand(1, false); // Fixed width
		blackboard_tree->set_column_custom_minimum_width(1, 200 * EDSCALE); // Adjust width

		// Third Column - Type
		blackboard_item->set_text(2, blackboard_info.type);
		blackboard_tree->set_column_expand(2, false); // Fixed width
		blackboard_tree->set_column_custom_minimum_width(2, 100 * EDSCALE); // Adjust width
	}

	// Update the tree with refreshed content.
	blackboard_tree->update_draw_order();
}

// Method to handle item edit
void BlackboardEditor::_on_item_edited(TreeItem *p_item, int p_column) {
	String edited_name = p_item->get_meta("__name");
	Variant new_value = p_item->get_text(p_column); // Fetch new value

	// Update the corresponding blackboard data
	if (p_column == 1) { // If value is edited
		Blackboard::get_singleton()->add_data(edited_name, new_value);
	}
}

BlackboardEditor::BlackboardEditor() {
	Blackboard::get_singleton()->load_data();
	// Main Vbox Container
	VBoxContainer *main_vbox = memnew(VBoxContainer);
	main_vbox->set_anchors_and_offsets_preset(PRESET_FULL_RECT);
	add_child(main_vbox);

	// Create tree
	blackboard_tree = memnew(Tree);
	blackboard_tree->set_v_size_flags(Control::SIZE_EXPAND_FILL);
	blackboard_tree->set_columns(3);
	blackboard_tree->set_hide_root(true);
	blackboard_tree->set_column_titles_visible(true);
	blackboard_tree->set_column_title(0, TTR("Name"));
	blackboard_tree->set_column_title(1, TTR("Value"));
	blackboard_tree->set_column_title(2, TTR("Type"));
	main_vbox->add_child(blackboard_tree);

	// Connect signals for tree interactions
	blackboard_tree->connect("item_edited", callable_mp(this, &BlackboardEditor::_on_item_edited));
	blackboard_tree->connect("button_clicked", callable_mp(this, &BlackboardEditor::_on_button_clicked));
}

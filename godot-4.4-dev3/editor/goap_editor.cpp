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

	goap_tree = memnew(Tree);
	goap_tree->set_v_size_flags(Control::SIZE_EXPAND_FILL);
	goap_tree->set_columns(3);
	goap_tree->set_hide_root(true);
	goap_tree->set_column_titles_visible(true);
	goap_tree->set_column_title(0, TTR("Name"));
	goap_tree->set_column_title(1, TTR("Preconditions"));
	goap_tree->set_column_title(2, TTR("Effects"));
	main_vbox->add_child(goap_tree);

	goap_tree->connect("item_edited", callable_mp(this, &GoapEditor::_on_item_edited));
	goap_tree->connect("button_clicked", callable_mp(this, &GoapEditor::_on_button_clicked));

}

void GoapEditor::update_goap_list(const Vector<Ref<GoapAction>> &p_actions) {
	if (!p_actions.is_empty()) {
		goap_cache = p_actions;
	}

	goap_tree->clear();

	TreeItem *root = goap_tree->create_item();

	for (int i = 0; i < goap_cache.size(); i++) {
		Ref<GoapAction> goap_action = goap_cache[i];

		TreeItem *goap_item = goap_tree->create_item(root);
		ERR_FAIL_NULL(goap_item);

		goap_item->set_meta("__name", goap_action->get_name());
		goap_item->set_meta("__preconditions", goap_action->get_preconditions());
		goap_item->set_meta("__effects", goap_action->get_effects());

		goap_item->set_text(0, goap_action->get_name());
		goap_tree->set_column_expand(0, true);

		goap_item->set_text(1, goap_action->get_preconditions()[0]);
		goap_tree->set_column_expand(1, false);

		goap_item->set_text(2, goap_action->get_effects()[0]);
		goap_tree->set_column_expand(2, false);

		goap_tree->set_column_custom_minimum_width(0, 200 * EDSCALE);
	}

	goap_tree->update_draw_order();
}

void GoapEditor::_bind_methods() {
}

void GoapEditor::_action_edited() {
}

void GoapEditor::_tree_item_activated() {
}

void GoapEditor::_tree_button_pressed() {
}

void GoapEditor::_on_button_clicked() {
}

void GoapEditor::_on_item_edited(TreeItem *p_item, int p_column) {
	String edited_name = p_item->get_meta("__name");
	Dictionary new_preconditions = p_item->get_meta("__preconditions");
	Dictionary new_effects = p_item->get_meta("__effects");

	if (p_column == 0) {
		edited_name = p_item->get_text(p_column);
	} else if (p_column == 1) {
		new_preconditions[0] = p_item->get_text(p_column);
	} else if (p_column == 2) {
		new_effects[0] = p_item->get_text(p_column);
	}
}

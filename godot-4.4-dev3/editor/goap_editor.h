#pragma once

#include "scene/gui/control.h"
#include "scene/resources/goap_action.h"
#include "gui/editor_file_dialog.h"

class Tree;

class GoapEditor : public Control {
	GDCLASS(GoapEditor, Control);

public:
	GoapEditor();
	void update_goap_list(const TypedArray<GoapAction> &p_actions);
	void add_goap_action(const Ref<GoapAction> &p_action);

protected:
	static void _bind_methods();

private:
	void _on_add_action_pressed();
	void _on_file_dialog_selected(const String &p_path);
	void _on_open_file_dialog_pressed();

	TypedArray<GoapAction> goap_cache;
	Tree *goap_tree = nullptr;
	Button *open_file_dialog_button = nullptr;
	EditorFileDialog *file_dialog = nullptr;

	void _update_goap_tree();
};

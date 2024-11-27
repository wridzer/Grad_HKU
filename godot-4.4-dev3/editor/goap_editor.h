#pragma once

#include "scene/gui/control.h"
#include "scene/resources/goap_action.h"

class Button;
class HBoxContainer;
class EventListenerLineEdit;
class LineEdit;
class CheckButton;
class AcceptDialog;
class InputEventConfigurationDialog;
class Tree;
class TreeItem;

class GoapEditor : public Control {
	GDCLASS(GoapEditor, Control);

public:

	GoapEditor();
	void update_goap_list(const Vector<Ref<GoapAction>> &p_actions);

protected:
	static void _bind_methods();

private:
	void _action_edited();
	void _tree_item_activated();
	void _tree_button_pressed();
	void _on_button_clicked();
	void _on_item_edited(TreeItem *p_item, int p_column);

	Vector<Ref<GoapAction>> goap_cache;
	Tree *goap_tree = nullptr;
};

#ifndef BLACKBOARD_EDITOR_H
#define BLACKBOARD_EDITOR_H

#include "scene/gui/control.h"

class Button;
class HBoxContainer;
class EventListenerLineEdit;
class LineEdit;
class CheckButton;
class AcceptDialog;
class InputEventConfigurationDialog;
class Tree;
class TreeItem;

class BlackboardEditor : public Control {
	GDCLASS(BlackboardEditor, Control);

public:
	struct BlackboardInfo {
		String name;
		Variant data;
		String type;
	};

	BlackboardEditor();
	void update_blackboard_list(const Vector<BlackboardInfo> &p_action_infos);

protected:
	static void _bind_methods();

private:
	void _action_edited();
	void _tree_item_activated();
	void _tree_button_pressed();
	void _on_button_clicked();
	void _on_item_edited(TreeItem *p_item, int p_column);

	Vector<BlackboardInfo> blackboard_cache;
	Tree *blackboard_tree = nullptr;
};

#endif // BLACKBOARD_EDITOR_H

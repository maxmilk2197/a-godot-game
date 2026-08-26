@tool
class_name DialogicStyleEvent
extends DialogicEvent

## Event that allows changing the currently displayed style.


### Settings

## The name of the style to change to. Can be set on the DialogicNode_Style.
@export var style_name := ""


#region EXECUTE
################################################################################

func _execute() -> void:
	dialogic.Styles.change_style(style_name)
	# we need to wait till the new layout is ready before continuing
	await dialogic.get_tree().process_frame
	finish()

#endregion


#region INITIALIZE
################################################################################

func _init() -> void:
	event_name = "Change Style"
	event_description = "切换到样式编辑器中配置的某个样式。"
	set_default_color('Color8')
	event_category = "Visuals"
	event_sorting_index = 1

#endregion


#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "style"


func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name : property_info
		"name" 		: {"property": "style_name", "default": "", 'suggestions':get_style_suggestions},
	}

#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('style_name', ValueType.DYNAMIC_OPTIONS, {
			'left_text'			:'使用样式',
			'placeholder'		: '默认',
			'suggestions_func' 	: get_style_suggestions,
			'editor_icon' 		: ["PopupMenu", "EditorIcons"],
			'autofocus'			: true})


func get_style_suggestions(_filter := "") -> Dictionary:
	var styles: Array = ProjectSettings.get_setting('dialogic/layout/style_list', [])

	var suggestions := {}
	suggestions['<默认样式>'] = {'value':'', 'editor_icon':["MenuBar", "EditorIcons"]}
	for i in styles:
		var style: DialogicStyle = load(i)
		suggestions[style.name] = {'value': style.name, 'editor_icon': ["PopupMenu", "EditorIcons"]}
	return suggestions

#endregion

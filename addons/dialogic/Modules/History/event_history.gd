@tool
class_name DialogicHistoryEvent
extends DialogicEvent

## Event that allows clearing, pausing and resuming of history functionality.

enum Actions {CLEAR, PAUSE, RESUME}

### Settings

## The type of action: Clear, Pause or Resume
@export var action := Actions.PAUSE


#region EXECUTION
################################################################################

func _execute() -> void:
	match action:
		Actions.CLEAR:
			dialogic.History.simple_history_content = []
		Actions.PAUSE:
			dialogic.History.simple_history_enabled = false
		Actions.RESUME:
			dialogic.History.simple_history_enabled = true

	finish()

#endregion


#region INITIALIZE
################################################################################

func _init() -> void:
	event_name = "History"
	event_description = "对简单历史执行一项操作。"
	set_default_color('Color9')
	event_category = "Other"
	event_sorting_index = 20

#endregion


#region SAVING/LOADING
################################################################################

func get_shortcode() -> String:
	return "history"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		"action" 			: {"property": "action", "default": Actions.PAUSE,
								"suggestions": func(): return {"清除":{'value':0, 'text_alt':['clear']}, "暂停":{'value':1, 'text_alt':['pause']}, "继续":{'value':2, 'text_alt':['resume', 'start']}}},
	}

#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_edit('action', ValueType.FIXED_OPTIONS, {
		'options': [
			{
				'label': '暂停历史',
				'value': Actions.PAUSE,
			},
			{
				'label': '继续历史',
				'value': Actions.RESUME,
			},
			{
				'label': '清除历史',
				'value': Actions.CLEAR,
			},
		]
		})

#endregion

@tool
class_name DialogicEndTimelineEvent
extends DialogicEvent

## Event that ends a timeline (even if more events come after).


#region EXECUTE
################################################################################

func _execute() -> void:
	dialogic.end_timeline()

#endregion


#region INITIALIZE
################################################################################

func _init() -> void:
	event_name = "End"
	event_description = "提前结束时间线。时间线末尾不必使用。"
	set_default_color('Color4')
	event_category = "Flow"
	event_sorting_index = 10

#endregion


#region SAVING/LOADING
################################################################################

func get_shortcode() -> String:
	return "end_timeline"

#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('结束时间线')

#endregion

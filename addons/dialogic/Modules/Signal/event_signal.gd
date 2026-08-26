@tool
class_name DialogicSignalEvent
extends DialogicEvent

## Event that emits the Dialogic.signal_event signal with an argument.
## You can connect to this signal like this: `Dialogic.signal_event.connect(myfunc)`


### Settings

enum ArgumentTypes {STRING, DICTIONARY}
## The type of argument to be given with the signal.
@export var argument_type := ArgumentTypes.STRING
## The argument that will be provided with the signal.
@export var argument: Variant = ""



#region EXECUTE
################################################################################

func _execute() -> void:
	if argument_type == ArgumentTypes.DICTIONARY:
		var result: Variant = JSON.parse_string(argument)
		if result != null:
			var dict := result as Dictionary
			dict.make_read_only()
			dialogic.emit_signal('signal_event', dict)
		else:
			push_error("[Dialogic] 信号事件中遇到无效字典。")
	else:
		dialogic.emit_signal('signal_event', argument)
	finish()

#endregion


#region INITIALIZE
################################################################################

func _init() -> void:
	event_name = "Signal"
	event_description = "发出带有指定参数的 Dialogic.signal_event 信号。你可以通过连接该信号在代码中做出响应。"
	set_default_color('Color6')
	event_category = "Logic"
	event_sorting_index = 8
	help_page_path = "https://docs.dialogic.pro/dialogic-signals.html#1-signal-event"

#endregion


#region SAVING/LOADING
################################################################################

func get_shortcode() -> String:
	return "signal"


func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name : property_info
		"arg_type"	: {"property": "argument_type", "default": ArgumentTypes.STRING,
										"suggestions": func(): return {"字符串":{'value':ArgumentTypes.STRING, 'text_alt':['string']}, "字典":{'value':ArgumentTypes.DICTIONARY, 'text_alt':['dict', 'dictionary']}}},
		"arg"		: {"property": "argument", "default": ""}
	}

#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label("发出带参数的 Dialogic 信号")
	add_header_label("（字典在正文中）", 'argument_type == ArgumentTypes.DICTIONARY')
	add_header_edit('argument', ValueType.SINGLELINE_TEXT, {}, 'argument_type == ArgumentTypes.STRING')
	add_body_edit('argument_type',ValueType.FIXED_OPTIONS, {'left_text':'参数类型：', 'options': [
			{
				'label': '字符串',
				'value': ArgumentTypes.STRING,
			},
			{
				'label': '字典',
				'value': ArgumentTypes.DICTIONARY,
			}
		]})
	add_body_line_break('argument_type == ArgumentTypes.DICTIONARY')
	add_body_edit('argument', ValueType.DICTIONARY, {'left_text': '字典'},'argument_type == ArgumentTypes.DICTIONARY')

#endregion

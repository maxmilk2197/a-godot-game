@tool
extends Node

@onready var ToolUtil := get_parent()

var button_text := "重新保存所有时间线"
var tooltip := "打开并重新保存所有时间线。如果更新引入了语法更改，这会很有用。"
var method := resave_tool


func resave_tool() -> void:
	ToolUtil.tool_progress_mutex.lock()
	ToolUtil.tool_progress = 0
	ToolUtil.tool_progress_mutex.unlock()

	var index := 0
	var timelines := DialogicResourceUtil.get_timeline_directory()
	for timeline_identifier in timelines:
		var timeline := DialogicResourceUtil.get_timeline_resource(timeline_identifier)
		await timeline.process()
		timeline.set_meta("timeline_not_saved", true)
		ResourceSaver.save(timeline)

		ToolUtil.tool_progress_mutex.lock()
		ToolUtil.tool_progress = 1.0/len(timelines)*index
		ToolUtil.tool_progress_mutex.unlock()

		index += 1

	ToolUtil.tool_progress_mutex.lock()
	ToolUtil.tool_progress = 1
	ToolUtil.tool_progress_mutex.unlock()

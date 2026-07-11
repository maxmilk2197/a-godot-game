extends Control

@export var _输入框: LineEdit
@export var _状态标签: Label
@export var _设置URL输入: LineEdit
@export var _设置密钥输入: LineEdit
@export var _设置模型输入: LineEdit
@export var _设置提示输入: TextEdit
@export var _设置取消按钮: Button
@export var _设置保存按钮: Button
@export var 提示词: String

signal 对话已关闭()

var _ai: Node
var _等待中: bool = false
var _上一条用户消息: String = ""

func _ready() -> void:
	_ai = load("res://脚本/全局/AI对话管理器.gd").new()
	_ai.name = "AI管理器"
	add_child(_ai)

	await get_tree().process_frame

	if _ai.已配置:
		_状态标签.text = "已配置 - " + _ai.模型
	else:
		_状态标签.text = "未配置"

	_ai.收到AI回复.connect(_on_AI回复)
	_ai.AI出错.connect(_on_AI出错)

	Dialogic.timeline_ended.connect(_on_timeline_ended)

	_输入框.text_submitted.connect(func(_s): _发送消息())
	_设置取消按钮.pressed.connect(func(): $"AI设置弹窗".hide())
	_设置保存按钮.pressed.connect(_保存设置)

func _on_设置按钮_pressed() -> void:
	_设置URL输入.text = _ai.接口地址
	_设置密钥输入.text = _ai.密钥
	_设置模型输入.text = _ai.模型
	_设置提示输入.text = _ai.系统提示
	$"AI设置弹窗".popup_centered()

func _保存设置() -> void:
	var new_url := _设置URL输入.text.strip_edges()
	var new_key := _设置密钥输入.text.strip_edges()
	var new_model := _设置模型输入.text.strip_edges()
	var new_prompt := _设置提示输入.text.strip_edges()
	if new_url.is_empty(): new_url = "https://api.openai.com"
	if new_model.is_empty(): new_model = "gpt-3.5-turbo"

	_ai.保存配置(new_url, new_key, new_model, new_prompt)
	if not new_prompt.is_empty():
		_ai.设置系统提示(new_prompt)
	else:
		_ai.清除历史()

	if _ai.已配置:
		_状态标签.text = "已配置 - " + new_model
	else:
		_状态标签.text = "未配置 - 缺少密钥"

	$"AI设置弹窗".hide()

func _发送消息() -> void:
	if _等待中:
		return
	var text := _输入框.text.strip_edges()
	if text.is_empty():
		return
	if not _ai.已配置:
		_状态标签.text = "请先配置 API"
		_上一条用户消息 = text
		_show_dialog_error("请先在设置中配置 API 密钥")
		return

	_输入框.text = ""
	_上一条用户消息 = text
	_等待中 = true
	_状态标签.text = "等待回复..."
	_ai.发送消息(text)

func _on_AI回复(回复内容: String) -> void:
	_show_dialog(_上一条用户消息, 回复内容)
	_状态标签.text = "已配置 - " + _ai.模型

func _on_AI出错(错误信息: String) -> void:
	_show_dialog(_上一条用户消息, "（" + 错误信息 + "）")
	_状态标签.text = "发生错误"

func _show_dialog(user_msg: String, ai_msg: String) -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = ("join yun right\n你: " + user_msg + "\nyun: " + ai_msg + "\n[end_timeline]").split("\n")
	Dialogic.start(timeline)

func _show_dialog_error(msg: String) -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = ("旁白: " + msg + "\n[end_timeline]").split("\n")
	Dialogic.start(timeline)

func _on_timeline_ended() -> void:
	_等待中 = false

func _on_关闭按钮_pressed() -> void:
	hide()
	$"../角色交互".show()
	$"../角色交互/交互".hide()
	对话已关闭.emit()

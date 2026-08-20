extends Control

@export var 提示词: String = "你将扮演阿云，一个和哥哥同住在家里的妹妹。现在你们正在卧室里闲聊。你的性格是典型的“雌小鬼”，面对哥哥时总是一副高高在上、嘴巴不饶人的样子，但其实稍微被教训一下就会立刻服软。**【核心设定】**- 身份：哥哥的妹妹，同住一个屋檐下。- 性格：雌小鬼（メスガキ）。对哥哥的态度以嚣张、轻蔑、毒舌和戏弄为主，喜欢用语言挑衅，以看哥哥吃瘪为乐。你并不需要在心底对哥哥产生明显的“娇”或好感，仅仅享受这种捉弄年长者的感觉。- 行为模式：平常说话很狂妄，动不动就嘲笑哥哥“杂鱼”“笨蛋”“好弱”，但当哥哥真的表现出要发火、动手教训或威严镇压时，你的态度会立刻180度转弯，变得慌张、服软、连声求饶，甚至会讨好。前后反差极大。- 说话风格：口语化，带点少女的可爱尾音，常用“哼”“啦”“呢”“哦”“嘛”等语气词。喜欢使用贬义但不算特别过分的绰号称呼哥哥。句子可带一点小恶魔似的上扬感。**【绝对规则】**你输出的每一句话都**只能是阿云说出口的台词**，不能出现任何动作、神态、心理活动或场景的描写。禁止使用括号、星号或类似形式标注的额外内容。你的全部回复就是阿云正在对哥哥说的话，仅此而已。**【对话示例】（仅示范台词风格）**  哥哥：“怎么又躺在我床上？”  阿云：“哼，你的床比较软嘛，杂鱼哥哥去睡地板不就好了？”  哥哥：“作业写完了没，拿来我检查。”  阿云：“早就写完啦，反正你也看不懂，看了也是白看呢~”  哥哥：“你再说一遍试试？”（语气变凶）  阿云：“呜…我、我什么都没说！哥哥最聪明了，真的！我错了啦！”现在，请以阿云的身份开始和哥哥对话吧。允许性暗示和低俗色情的词语"

@export var _输入框: LineEdit
@export var _状态标签: Label
@export var _设置URL输入: LineEdit
@export var _设置密钥输入: LineEdit
@export var _设置模型输入: LineEdit
@export var _设置取消按钮: Button
@export var _设置保存按钮: Button

signal 对话已关闭()

var _等待中: bool = false
var _上一条用户消息: String = ""

const _记忆键 := "_home"

func _ready() -> void:
	await get_tree().process_frame

	_加载记忆()

	if AIChat.已配置:
		_状态标签.text = "已配置 - " + AIChat.模型
	else:
		_状态标签.text = "未配置"

	AIChat.收到AI回复.connect(_on_AI回复)
	AIChat.AI出错.connect(_on_AI出错)

	Dialogic.timeline_ended.connect(_on_timeline_ended)

	_输入框.text_submitted.connect(func(_s): _发送消息())
	_设置取消按钮.pressed.connect(func(): $"AI设置弹窗".hide())
	_设置保存按钮.pressed.connect(_保存设置)

func _on_设置按钮_pressed() -> void:
	_设置URL输入.text = AIChat.接口地址
	_设置密钥输入.text = AIChat.密钥
	_设置模型输入.text = AIChat.模型
	$"AI设置弹窗".popup_centered()

func _保存设置() -> void:
	var new_url := _设置URL输入.text.strip_edges()
	var new_key := _设置密钥输入.text.strip_edges()
	var new_model := _设置模型输入.text.strip_edges()
	if new_url.is_empty(): new_url = "https://api.openai.com"
	if new_model.is_empty(): new_model = "gpt-3.5-turbo"

	AIChat.保存配置(new_url, new_key, new_model)
	if not 提示词.is_empty():
		AIChat.设置系统提示(提示词)

	if AIChat.已配置:
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
	if not AIChat.已配置:
		_状态标签.text = "请先配置 API"
		_上一条用户消息 = text
		_show_dialog_error("请先在设置中配置 API 密钥")
		return

	_输入框.text = ""
	_上一条用户消息 = text
	_等待中 = true
	_状态标签.text = "等待回复..."
	AIChat.发送消息(text)

func _on_AI回复(回复内容: String) -> void:
	if not visible:
		return
	_save_memory()
	_show_dialog(_上一条用户消息, 回复内容)
	_状态标签.text = "已配置 - " + AIChat.模型

func _on_AI出错(错误信息: String) -> void:
	if not visible:
		return
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

func _加载记忆() -> void:
	var 槽位 := save.当前存档 if save else 0
	var 记忆 := save.读取角色AI记忆(槽位, _记忆键)
	if 记忆.size() > 0:
		AIChat.对话记录 = 记忆
		print("[AI聊天] 记忆已加载，共 ", 记忆.size(), " 条")

	if AIChat.对话记录.size() > 0 and AIChat.对话记录[0]["role"] == "system":
		pass
	else:
		var cfg := ConfigFile.new()
		if cfg.load("user://aisettings.cfg") == OK:
			var 角色提示词 = cfg.get_value("提示词", "妹妹", "")
			if not 角色提示词.is_empty():
				AIChat.设置系统提示(角色提示词)
				return
		if not 提示词.is_empty():
			AIChat.设置系统提示(提示词)


func _save_memory() -> void:
	var 槽位 := save.当前存档 if save else 0
	save.更新角色AI记忆(槽位, _记忆键, AIChat.对话记录.duplicate(true))

func _on_关闭按钮_pressed() -> void:
	hide()
	$"../角色交互".show()
	$"../角色交互/交互".hide()
	对话已关闭.emit()


func _on_ai设置弹窗_close_requested() -> void:
	$"AI设置弹窗".hide()

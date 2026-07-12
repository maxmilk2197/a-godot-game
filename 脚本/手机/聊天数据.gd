# 聊天数据模型 - 管理联系人、消息持久化、AI记忆、角色提示词
class_name 聊天数据
extends RefCounted

const 存储目录 := "user://Saves/"
const 设置路径 := "user://aisettings.cfg"

static var 联系人数据: Dictionary = {}
static var 当前槽位: int = 0
static var 当前同步的联系人: String = ""

static var _默认妹妹消息 := [
	{"发送者": "妹妹", "内容": "哥哥早呀~", "时间": "昨天 08:15"},
	{"发送者": "我", "内容": "早啊小懒虫", "时间": "昨天 08:16"},
	{"发送者": "妹妹", "内容": "今天做什么好吃的给我？", "时间": "昨天 08:17"},
	{"发送者": "我", "内容": "你想吃什么？", "时间": "昨天 08:18"},
	{"发送者": "妹妹", "内容": "草莓蛋糕！还有奶茶！", "时间": "昨天 08:18"},
	{"发送者": "我", "内容": "一大早吃这些……行吧", "时间": "昨天 08:19"},
	{"发送者": "妹妹", "内容": "嘻嘻，哥哥最好了~", "时间": "昨天 08:20"},
	{"发送者": "妹妹", "内容": "哥哥你在干嘛呀~", "时间": "10:30"},
]

static var _默认阿云消息 := [
	{"发送者": "阿云", "内容": "早上好", "时间": "09:00"},
	{"发送者": "我", "内容": "早呀阿云", "时间": "09:01"},
	{"发送者": "阿云", "内容": "今天的任务完成了吗？", "时间": "09:15"},
]

static var 联系人提示词 := {}

const 默认_妹妹提示词 := "你将扮演妹妹，一个和哥哥同住在家里的女孩。性格是典型的'雌小鬼'，对哥哥嚣张、轻蔑、毒舌，喜欢用语言挑衅。平常说话狂妄，但当哥哥真的发火时立刻服软求饶。说话口语化，常用'哼''啦''呢''哦''嘛'。你输出的每一句话都只能是你说的台词，不能有动作或心理描写。回复要简短自然。"

const 默认_阿云提示词 := "你将扮演阿云，从小一起长大的青梅竹马。她和你是邻居，性格活泼开朗，有点小傲娇但很关心你。喜欢用略带嫌弃的语气关心人，偶尔会吐槽你。说话风格俏皮可爱，常用'哼''嘛''啊'。你输出的每一句话都只能是你说的台词，不能有动作或心理描写。回复要简短自然。"


static func _确保角色提示词() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(设置路径) != OK:
		cfg.set_value("提示词", "妹妹", 默认_妹妹提示词)
		cfg.set_value("提示词", "阿云", 默认_阿云提示词)
		cfg.save(设置路径)
		return
	if not cfg.has_section_key("提示词", "妹妹"):
		cfg.set_value("提示词", "妹妹", 默认_妹妹提示词)
		cfg.save(设置路径)
	if not cfg.has_section_key("提示词", "阿云"):
		cfg.set_value("提示词", "阿云", 默认_阿云提示词)
		cfg.save(设置路径)


static func _加载角色提示词() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(设置路径) != OK:
		return
	联系人提示词["妹妹"] = cfg.get_value("提示词", "妹妹", 默认_妹妹提示词)
	联系人提示词["阿云"] = cfg.get_value("提示词", "阿云", 默认_阿云提示词)


static func 初始化(槽位: int = -1) -> void:
	if 槽位 < 0:
		槽位 = save.当前存档 if save else 0
	当前槽位 = 槽位
	当前同步的联系人 = ""
	_确保角色提示词()
	_加载角色提示词()
	联系人数据 = {
		"妹妹": {
			"名称": "妹妹",
			"头像颜色": Color(1, 0.419608, 0.615686, 1),
			"头像文字": "妹",
			"消息": _默认妹妹消息.duplicate(true),
			"最后消息": "哥哥你在干嘛呀~",
			"最后时间": "10:30",
		},
		"阿云": {
			"名称": "阿云",
			"头像颜色": Color(0.305882, 0.803922, 0.768627, 1),
			"头像文字": "云",
			"消息": _默认阿云消息.duplicate(true),
			"最后消息": "今天的任务完成了吗？",
			"最后时间": "09:15",
		},
	}
	_从存档加载全部()


static func _从存档加载全部() -> void:
	for contact_name in 联系人数据:
		var msgs = save.读取聊天记录(当前槽位, contact_name)
		if msgs is Array and msgs.size() > 0:
			联系人数据[contact_name]["消息"] = msgs
			var last = msgs[-1]
			联系人数据[contact_name]["最后消息"] = last.get("内容", "")
			联系人数据[contact_name]["最后时间"] = last.get("时间", "")


static func _保存到存档(联系人名: String) -> void:
	var data = 联系人数据[联系人名]["消息"]
	save.更新聊天记录(当前槽位, 联系人名, data)


static func 获取联系人列表() -> Array:
	var result: Array = []
	for key in 联系人数据:
		result.append(联系人数据[key])
	return result


static func 获取联系人(名称: String) -> Dictionary:
	return 联系人数据.get(名称, {})


static func 添加消息(联系人名: String, 发送者: String, 内容: String) -> void:
	var contact = 联系人数据.get(联系人名, {})
	if contact.is_empty():
		return
	var 时间文本 = _当前时间文本()
	var msg = {"发送者": 发送者, "内容": 内容, "时间": 时间文本}
	contact["消息"].append(msg)
	contact["最后消息"] = 内容
	contact["最后时间"] = 时间文本
	_保存到存档(联系人名)


static func 获取提示词(联系人名: String) -> String:
	return 联系人提示词.get(联系人名, "")


static func _保存AI记忆(联系人名: String) -> void:
	if AIChat.对话记录.is_empty():
		return
	save.更新角色AI记忆(当前槽位, 联系人名, AIChat.对话记录.duplicate(true))


static func _加载AI记忆到AIChat(联系人名: String) -> void:
	var mem = save.读取角色AI记忆(当前槽位, 联系人名)
	if mem.size() > 0:
		AIChat.对话记录 = mem.duplicate(true)


static func _初次种子AI记忆(联系人名: String) -> void:
	var contact = 联系人数据.get(联系人名, {})
	if contact.is_empty():
		return
	for msg in contact["消息"]:
		if msg["发送者"] == "我":
			AIChat.对话记录.append({"role": "user", "content": msg["内容"]})
		elif msg["发送者"] == 联系人名:
			AIChat.对话记录.append({"role": "assistant", "content": msg["内容"]})


static func 切换AI联系人(新联系人: String) -> void:
	if 新联系人 == 当前同步的联系人:
		return

	if not 当前同步的联系人.is_empty():
		_保存AI记忆(当前同步的联系人)

	当前同步的联系人 = 新联系人
	var 提示词 = 联系人提示词.get(新联系人, "")
	if not 提示词.is_empty():
		AIChat.设置系统提示(提示词)

	var mem = save.读取角色AI记忆(当前槽位, 新联系人)
	if mem.size() > 0:
		_加载AI记忆到AIChat(新联系人)
	else:
		_初次种子AI记忆(新联系人)


static func 保存当前AI记忆() -> void:
	if 当前同步的联系人.is_empty():
		return
	_保存AI记忆(当前同步的联系人)


static func _当前时间文本() -> String:
	var d = Time.get_datetime_dict_from_system()
	return "%02d:%02d" % [d.hour, d.minute]


static func 复制到槽位(新槽位: int) -> void:
	if 当前槽位 == 新槽位:
		return
	var all_records = save.读取全部聊天记录(当前槽位)
	for contact_name in all_records:
		save.更新聊天记录(新槽位, contact_name, all_records[contact_name])
	var mem_all = save.读取AI记忆(当前槽位)
	if mem_all.size() > 0:
		save.更新AI记忆(新槽位, mem_all)
	for contact_name in 联系人数据:
		var mem = save.读取角色AI记忆(当前槽位, contact_name)
		if mem.size() > 0:
			save.更新角色AI记忆(新槽位, contact_name, mem)

extends Node

@export var 当前存档: int = 0
@export var 存档目录: String = "user://Saves/"
var 完整路径: String = ""

var 默认存档: Dictionary = {
	"游玩天数": 0,
	"最后游玩场景": "",
	"最后游玩时间": "",
	"上次存档": 0,
	"金钱数量": 1000,
	"ai_memory": {
		"_global": [],
	},
	"chat_records": {},
}


func _ready() -> void:
	更新文件路径()


func 更新文件路径() -> void:
	完整路径 = 存档目录 + "save_" + str(当前存档) + ".json"


func _补全默认键(数据: Dictionary) -> void:
	for key in 默认存档:
		if not 数据.has(key):
			数据[key] = 默认存档[key]


func _写文件(路径: String, 数据: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(存档目录)
	var json_text = JSON.stringify(数据)
	var file = FileAccess.open(路径, FileAccess.WRITE)
	if file == null:
		printerr("[错误]无法创建文件: ", 路径)
		return false
	file.store_string(json_text)
	file.close()
	return true


func _读文件(路径: String) -> Dictionary:
	if not FileAccess.file_exists(路径):
		return {}
	var file = FileAccess.open(路径, FileAccess.READ)
	if file == null:
		return {}
	var text = file.get_as_text()
	file.close()
	var result = JSON.parse_string(text)
	return result if result is Dictionary else {}


func 保存(存档数据: Dictionary) -> bool:
	var 现有 = _读文件(完整路径)
	for key in 存档数据:
		现有[key] = 存档数据[key]
	var ok = _写文件(完整路径, 现有)
	if ok:
		print("[信息]成功保存到槽位 ", 当前存档)
	return ok


func 保存指定槽位(槽位编号: int, 存档数据: Dictionary) -> bool:
	var 路径 = 存档目录 + "save_" + str(槽位编号) + ".json"
	var 现有 = _读文件(路径)
	for key in 存档数据:
		现有[key] = 存档数据[key]
	var ok = _写文件(路径, 现有)
	if ok:
		print("[信息]成功保存到槽位 ", 槽位编号)
	return ok


func 自动保存(存档数据: Dictionary) -> bool:
	return 保存指定槽位(0, 存档数据)


func 加载() -> Dictionary:
	var 数据 = _读文件(完整路径)
	if 数据.is_empty():
		return 默认存档.duplicate(true)
	_补全默认键(数据)
	print("[信息]加载成功: ", 完整路径)
	return 数据


func 切换槽位(新槽位: int) -> void:
	当前存档 = 新槽位
	更新文件路径()
	print("[信息]已切换到槽位 ", 当前存档)


func 检查当前槽位有无存档() -> bool:
	return FileAccess.file_exists(完整路径)


func 检查槽位有无存档(槽位号: int) -> bool:
	var 指定路径 = 存档目录 + "save_" + str(槽位号) + ".json"
	return FileAccess.file_exists(指定路径)


func 加载指定槽位(槽位编号: int) -> Dictionary:
	var 路径 = 存档目录 + "save_" + str(槽位编号) + ".json"
	var 数据 = _读文件(路径)
	if 数据.is_empty():
		return 默认存档.duplicate(true)
	_补全默认键(数据)
	print("[信息]指定加载已读取槽位 ", 槽位编号)
	return 数据


func 删除当前存档() -> void:
	if FileAccess.file_exists(完整路径):
		DirAccess.remove_absolute(完整路径)
		print("[信息]已删除槽位 ", 当前存档)


func 是否有任意存档() -> bool:
	var dir = DirAccess.open(存档目录)
	if dir == null:
		printerr("无法打开存档目录: ", 存档目录)
		return false

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("save_") and file_name.ends_with(".json"):
			var 中部 = file_name.trim_prefix("save_").trim_suffix(".json")
			if 中部.is_valid_int():
				dir.list_dir_end()
				return true
		file_name = dir.get_next()

	dir.list_dir_end()
	return false


var _ai记忆缓存: Dictionary = {}


func 当前AI记忆() -> Array:
	if not _ai记忆缓存.has(当前存档):
		_ai记忆缓存[当前存档] = 读取AI记忆(当前存档)
	return _ai记忆缓存[当前存档]


func 设置当前AI记忆(记忆: Array) -> void:
	_ai记忆缓存[当前存档] = 记忆.duplicate(true)
	更新AI记忆(当前存档, 记忆)


func 清除当前AI记忆缓存() -> void:
	_ai记忆缓存.erase(当前存档)


func _确保内存结构(数据: Dictionary) -> void:
	if not 数据.has("ai_memory") or not 数据["ai_memory"] is Dictionary:
		数据["ai_memory"] = {"_global": []}
	elif not 数据["ai_memory"].has("_global"):
		数据["ai_memory"]["_global"] = []
	if not 数据.has("chat_records") or not 数据["chat_records"] is Dictionary:
		数据["chat_records"] = {}


func 更新AI记忆(槽位: int, 记忆: Array) -> void:
	_ai记忆缓存[槽位] = 记忆
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 数据 := _读文件(路径)
	if 数据.is_empty():
		数据 = 默认存档.duplicate(true)
	_确保内存结构(数据)
	数据["ai_memory"]["_global"] = 记忆
	_写文件(路径, 数据)
	print("[存档] AI记忆已写入槽位 ", 槽位)


func 读取AI记忆(槽位: int) -> Array:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 数据 := _读文件(路径)
	if 数据.is_empty():
		return []
	var mem = 数据.get("ai_memory", {})
	if mem is Dictionary:
		var global_mem = mem.get("_global", [])
		if global_mem is Array:
			print("[存档] AI记忆已读取，共 ", global_mem.size(), " 条")
			return global_mem
	return []


func 更新角色AI记忆(槽位: int, 角色名: String, 记忆: Array) -> void:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 数据 := _读文件(路径)
	if 数据.is_empty():
		数据 = 默认存档.duplicate(true)
	_确保内存结构(数据)
	数据["ai_memory"][角色名] = 记忆
	_写文件(路径, 数据)


func 读取角色AI记忆(槽位: int, 角色名: String) -> Array:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 数据 := _读文件(路径)
	if 数据.is_empty():
		return []
	var mem = 数据.get("ai_memory", {})
	if mem is Dictionary:
		var 角色记忆 = mem.get(角色名, [])
		if 角色记忆 is Array:
			return 角色记忆
	return []


func 更新聊天记录(槽位: int, 角色名: String, 消息列表: Array) -> void:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 数据 := _读文件(路径)
	if 数据.is_empty():
		数据 = 默认存档.duplicate(true)
	_确保内存结构(数据)
	数据["chat_records"][角色名] = 消息列表
	_写文件(路径, 数据)


func 读取聊天记录(槽位: int, 角色名: String) -> Array:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 数据 := _读文件(路径)
	if 数据.is_empty():
		return []
	var records = 数据.get("chat_records", {})
	if records is Dictionary:
		var msgs = records.get(角色名, [])
		if msgs is Array:
			return msgs
	return []


func 读取全部聊天记录(槽位: int) -> Dictionary:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 数据 := _读文件(路径)
	if 数据.is_empty():
		return {}
	var records = 数据.get("chat_records", {})
	return records if records is Dictionary else {}

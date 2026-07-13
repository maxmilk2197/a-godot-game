extends Node

@export var 当前存档: int = 0
@export var 存档目录: String = "user://Saves/"
var 完整路径: String = ""

var 默认存档: Dictionary = {
	"游玩天数": 0,
	"最后游玩场景": "",
	"最后游玩时间": "",
	"上次存档": 0,
	"金钱数量": 100,
	"角色数据": {},
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


func _读角色数据(槽位: int, 角色名: String) -> Dictionary:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 数据 := _读文件(路径)
	if 数据.is_empty():
		数据 = 默认存档.duplicate(true)
	_确保结构(数据)
	var 角色数据 = 数据["角色数据"]
	if not 角色数据.has(角色名):
		角色数据[角色名] = {}
	return 角色数据[角色名]


func _确保结构(数据: Dictionary) -> void:
	if not 数据.has("角色数据") or not 数据["角色数据"] is Dictionary:
		数据["角色数据"] = {}


func 更新角色AI记忆(槽位: int, 角色名: String, 记忆: Array) -> void:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 角色数据 := _读角色数据(槽位, 角色名)
	角色数据["ai_memory"] = 记忆
	var 文件数据 := _读文件(路径)
	if 文件数据.is_empty():
		文件数据 = 默认存档.duplicate(true)
	_确保结构(文件数据)
	文件数据["角色数据"][角色名] = 角色数据
	_写文件(路径, 文件数据)


func 读取角色AI记忆(槽位: int, 角色名: String) -> Array:
	var 角色数据 := _读角色数据(槽位, 角色名)
	var mem = 角色数据.get("ai_memory", [])
	if mem is Array:
		return mem
	return []


func 更新聊天记录(槽位: int, 角色名: String, 消息列表: Array) -> void:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 角色数据 := _读角色数据(槽位, 角色名)
	角色数据["chat_records"] = 消息列表
	var 文件数据 := _读文件(路径)
	if 文件数据.is_empty():
		文件数据 = 默认存档.duplicate(true)
	_确保结构(文件数据)
	文件数据["角色数据"][角色名] = 角色数据
	_写文件(路径, 文件数据)


func 读取聊天记录(槽位: int, 角色名: String) -> Array:
	var 角色数据 := _读角色数据(槽位, 角色名)
	var records = 角色数据.get("chat_records", [])
	if records is Array:
		return records
	return []


func 读取全部聊天记录(槽位: int) -> Dictionary:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 数据 := _读文件(路径)
	if 数据.is_empty():
		return {}
	var 角色数据 = 数据.get("角色数据", {})
	if not 角色数据 is Dictionary:
		return {}
	var result: Dictionary = {}
	for 角色名 in 角色数据:
		var entry = 角色数据[角色名]
		if entry is Dictionary and entry.has("chat_records"):
			result[角色名] = entry["chat_records"]
	return result


func 复制角色数据(源槽位: int, 目标槽位: int, 角色名: String) -> void:
	var 源角色数据 := _读角色数据(源槽位, 角色名)
	if 源角色数据.is_empty():
		return
	var 路径 := 存档目录 + "save_" + str(目标槽位) + ".json"
	var 文件数据 := _读文件(路径)
	if 文件数据.is_empty():
		文件数据 = 默认存档.duplicate(true)
	_确保结构(文件数据)
	文件数据["角色数据"][角色名] = 源角色数据.duplicate(true)
	_写文件(路径, 文件数据)

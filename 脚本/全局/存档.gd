extends Node

@export var 当前存档: int = 0
@export var 存档目录: String = "user://Saves/"
var 完整路径: String = ""

## 默认存档模板，所有新字段都加在这里，加载时自动补全缺失项
var 默认存档: Dictionary = {
	"游玩天数": 0,
	"最后游玩场景": "",
	"最后游玩时间": "",
	"上次存档": 0,
	"金钱数量": 100,
	"ai_memory": [],
}


func _ready() -> void:
	更新文件路径()


func 更新文件路径() -> void:
	完整路径 = 存档目录 + "save_" + str(当前存档) + ".json"


## 保存当前槽位（存档数据需为 Dictionary）
func 保存(存档数据: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(存档目录)

	var json_text = JSON.stringify(存档数据)
	var file = FileAccess.open(完整路径, FileAccess.WRITE)
	if file == null:
		printerr("[错误]无法创建文件: ", 完整路径)
		return false

	file.store_string(json_text)
	file.close()
	print("[信息]成功保存到槽位 ", 当前存档)
	return true


## 保存到指定槽位（存档数据为 Dictionary）
func 保存指定槽位(槽位编号: int, 存档数据: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(存档目录)
	var 路径 = 存档目录 + "save_" + str(槽位编号) + ".json"
	var json_text = JSON.stringify(存档数据)
	var file = FileAccess.open(路径, FileAccess.WRITE)
	if file == null:
		printerr("[错误]保存到槽位 %d 失败: 无法创建文件 " % 槽位编号, 路径)
		return false

	file.store_string(json_text)
	file.close()
	print("[信息]成功保存到槽位 ", 槽位编号)
	return true


## 自动保存（默认槽位 0）
func 自动保存(存档数据: Dictionary) -> bool:
	return 保存指定槽位(0, 存档数据)

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


## 加载当前槽位的存档（自动补全默认值，返回 Dictionary）
func 加载() -> Dictionary:
	if not FileAccess.file_exists(完整路径):
		printerr("[错误]存档文件不存在:", 完整路径)
		return 默认存档.duplicate(true)

	var file = FileAccess.open(完整路径, FileAccess.READ)
	if file == null:
		printerr("[错误]无法打开文件: ", 完整路径)
		return 默认存档.duplicate(true)

	var json_text = file.get_as_text()
	file.close()

	var 结果 = JSON.parse_string(json_text)
	if 结果 == null or not 结果 is Dictionary:
		printerr("[错误]解析 JSON 失败: ", 完整路径)
		return 默认存档.duplicate(true)

	# 补全缺失的键
	for key in 默认存档:
		if not 结果.has(key):
			结果[key] = 默认存档[key]
	print("[信息]加载成功: ", 完整路径)
	return 结果


## 切换当前槽位
func 切换槽位(新槽位: int) -> void:
	当前存档 = 新槽位
	更新文件路径()
	print("[信息]已切换到槽位 ", 当前存档)


## 检查当前槽位是否有存档文件
func 检查当前槽位有无存档() -> bool:
	return FileAccess.file_exists(完整路径)


## 检查指定槽位是否存在存档
func 检查槽位有无存档(槽位号: int) -> bool:
	var 指定路径 = 存档目录 + "save_" + str(槽位号) + ".json"
	return FileAccess.file_exists(指定路径)


## 加载指定槽位的存档（自动补全默认值，返回 Dictionary）
func 加载指定槽位(槽位编号: int) -> Dictionary:
	var 路径 = 存档目录 + "save_" + str(槽位编号) + ".json"
	if not FileAccess.file_exists(路径):
		printerr("[错误]指定加载槽位 %d 存档文件不存在: " % 槽位编号, 路径)
		return 默认存档.duplicate(true)

	var file = FileAccess.open(路径, FileAccess.READ)
	if file == null:
		printerr("[错误]无法打开文件: ", 路径)
		return 默认存档.duplicate(true)

	var json_text = file.get_as_text()
	file.close()

	var 结果 = JSON.parse_string(json_text)
	if 结果 == null or not 结果 is Dictionary:
		printerr("[错误]指定加载槽位 %d JSON 解析失败: " % 槽位编号, 路径)
		return 默认存档.duplicate(true)

	# 补全缺失的键
	for key in 默认存档:
		if not 结果.has(key):
			结果[key] = 默认存档[key]
	print("[信息]指定加载已读取槽位 ", 槽位编号)
	return 结果


## 删除当前槽位的存档
func 删除当前存档() -> void:
	if FileAccess.file_exists(完整路径):
		DirAccess.remove_absolute(完整路径)
		print("[信息]已删除槽位 ", 当前存档)


## 检查存档目录中是否存在任意有效存档（文件名格式：save_数字.json）
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


func 更新AI记忆(槽位: int, 记忆: Array) -> void:
	_ai记忆缓存[槽位] = 记忆
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	var 数据 := {}
	if FileAccess.file_exists(路径):
		var file := FileAccess.open(路径, FileAccess.READ)
		if file:
			var text := file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(text)
			if parsed is Dictionary:
				数据 = parsed
	数据["ai_memory"] = 记忆
	var wfile := FileAccess.open(路径, FileAccess.WRITE)
	if wfile:
		wfile.store_string(JSON.stringify(数据))
		wfile.close()
		print("[存档] AI记忆已写入槽位 ", 槽位)


func 读取AI记忆(槽位: int) -> Array:
	var 路径 := 存档目录 + "save_" + str(槽位) + ".json"
	if not FileAccess.file_exists(路径):
		return []
	var file := FileAccess.open(路径, FileAccess.READ)
	if file:
		var text := file.get_as_text()
		file.close()
		var 结果 = JSON.parse_string(text)
		if 结果 is Dictionary and 结果.has("ai_memory"):
			var mem = 结果["ai_memory"]
			if mem is Array:
				print("[存档] AI记忆已读取，共 ", mem.size(), " 条")
				return mem
	return []

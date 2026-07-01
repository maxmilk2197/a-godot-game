extends Node


@export var 当前存档: int = 0:                                                    ##存档槽位
	set(编号):
		当前存档 = max(0, 编号)                                                                       ##防止非法槽位被输入
		更新文件路径()

@export var 存档目录: String = "user://Saves/"

var 完整路径: String = ""                                                         ##根据当前槽位拼出的完整文件路径（自动生成，只读）

func _ready() -> void:
	更新文件路径()

func 更新文件路径() -> void:
	完整路径 = 存档目录 + "save_" + str(当前存档) + ".tres"                          ##计算完整路径


func 保存(存档数据: Resource) -> bool:
	# 确保存档目录存在
	DirAccess.make_dir_recursive_absolute(存档目录)
	
	var 错误码 = ResourceSaver.save(存档数据, 完整路径)
	if 错误码 != OK:
		printerr("[错误]保存失败: ", 错误码, " 路径: ", 完整路径)
		return false
	print("[信息]成功保存到槽位 ", 当前存档)
	return true


func 保存指定槽位(槽位编号: int, 存档数据: Resource) -> bool:
	DirAccess.make_dir_recursive_absolute(存档目录)
	var 路径 = 存档目录 + "save_" + str(槽位编号) + ".tres"
	var 错误码 = ResourceSaver.save(存档数据, 路径)
	if 错误码 != OK:
		printerr("[错误]保存到槽位 %d 失败: " % 槽位编号, 错误码, " 路径: ", 路径)
		return false
	print("[信息]成功保存到槽位 ", 槽位编号)
	return true

func 自动保存(存档数据: Resource) -> bool:
	return 保存指定槽位(0, 存档数据)

func 加载() -> Resource:                                                         ## 加载当前槽位的存档
	if not FileAccess.file_exists(完整路径):
		printerr("[错误]存档文件不存在:", 完整路径)
		return null

	var 加载结果 = load(完整路径)
	if 加载结果 == null:
		printerr("[错误]加载存档失败:", 完整路径)
	else:
		print("[信息]加载成功: ", 完整路径)
	return 加载结果


func 切换槽位(新槽位: int) -> void:                                               ## 切换到指定槽位
	当前存档 = 新槽位
	print("[信息]已切换到槽位 ", 当前存档)


func 检查当前槽位有无存档() -> bool:                                               ## 检查当前槽位是否有存档文件
	return FileAccess.file_exists(完整路径)

## 检查指定槽位是否存在存档（从外部传入槽位号）
func 检查槽位有无存档(槽位号: int) -> bool:
	var 指定路径 = 存档目录 + "save_" + str(槽位号) + ".tres"
	return FileAccess.file_exists(指定路径)

func 加载指定槽位(槽位编号: int) -> Resource:
	var 路径 = 存档目录 + "save_" + str(槽位编号) + ".tres"
	if not FileAccess.file_exists(路径):
		printerr("[错误]指定加载槽位 %d 存档文件不存在: " % 槽位编号, 路径)
		return null

	var 结果 = load(路径)
	if 结果 == null:
		printerr("[错误]指定加载槽位 %d 失败: " % 槽位编号, 路径)
	else:
		print("[信息]指定加载已读取槽位 ", 槽位编号)
	return 结果


func 删除当前存档() -> void:                                                ##删除当前槽位的存档
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
		# 严格检查：去掉前缀后缀后剩下的必须是纯数字
		if file_name.begins_with("save_") and file_name.ends_with(".tres"):
			var 中部 = file_name.trim_prefix("save_").trim_suffix(".tres")
			if 中部.is_valid_int():        # 确保是整数，排除空串、字母等
				dir.list_dir_end()
				return true
		file_name = dir.get_next()

	dir.list_dir_end()
	return false

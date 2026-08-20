extends Node
## ============================================================
## 设置数据（全局唯一，autoload 注册名：Settings）
## 存放各可微调开关/选项，持久化到 user://game_settings.cfg。
## 用法（脚本里读/写都会自动保存）：
##   Settings.显示对方头像 = false
##   if Settings.显示对方头像: ...
## ============================================================

const 设置路径 := "user://game_settings.cfg"

## 聊天界面里是否显示「对方」消息旁的头像
var 显示对方头像: bool = true:
	set(值):
		显示对方头像 = 值
		保存()


func _ready() -> void:
	读取()


## 从配置文件恢复所有设置项
func 读取() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(设置路径) != OK:
		return
	显示对方头像 = cfg.get_value("聊天", "显示对方头像", true)


## 把当前所有设置项写入配置文件
func 保存() -> void:
	var cfg := ConfigFile.new()
	cfg.load(设置路径)
	cfg.set_value("聊天", "显示对方头像", 显示对方头像)
	cfg.save(设置路径)

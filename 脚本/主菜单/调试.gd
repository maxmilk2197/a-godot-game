extends Control
@export var 是否启用开发者模式:bool=false
func _ready() -> void:
	info.开发者模式 = 是否启用开发者模式
	if info.开发者模式:
		$"./设备类型".text ="是否为移动设备:"+ str(info.设备是否为移动设备)
	

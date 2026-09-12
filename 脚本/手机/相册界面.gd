extends Control
## 手机相册应用：全屏显示照片壁纸，可返回。

@onready var 相片显示 = $"相片"
@onready var 空白提示 = $"空白提示"


func _ready() -> void:
	# 相片默认铺满；加载到的照片在场景里已绑定
	相片显示.modulate = Color(1, 1, 1, 1)
	# 相片按尺寸做圆角裁剪，跟手机屏幕圆角一致
	_更新相片圆角()
	相片显示.resized.connect(_更新相片圆角)


func _更新相片圆角() -> void:
	var mat := 相片显示.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("rect_size", 相片显示.size)


func 设置相片(路径: String) -> void:
	if ResourceLoader.exists(路径):
		相片显示.texture = load(路径)
		空白提示.visible = false


func _on_关闭按钮_pressed() -> void:
	var phone = get_parent()
	while phone and not phone.has_method("关闭当前应用"):
		phone = phone.get_parent()
	if phone and phone.has_method("关闭当前应用"):
		phone.关闭当前应用()

# Material 3 UI Kit（GDScript 版）

Godot 4 的 Material Design 3 组件库，**纯 GDScript**，不需要 .NET / Mono。
是 [`rnewquist/godot_material3`](https://github.com/rnewquist/godot_material3)（C# 版）的 GDScript 移植版。

- 目录：`addons/material_ui/`
- 启用插件后会自动注册 `M3ThemeManager` 单例（可选，不用也行）

## 组件一览

| 类名 | 继承 | 说明 |
|---|---|---|
| `M3Button` | Button | Filled / Tonal / Outlined / Text / Elevated，自带涟漪 |
| `M3Card` | PanelContainer | Elevated / Filled / Outlined 卡片容器 |
| `M3Switch` | BaseButton | 开关（`button_pressed`） |
| `M3Checkbox` | BaseButton | 复选框（`button_pressed`） |
| `M3RadioButton` | BaseButton | 单选按钮（`button_pressed`） |
| `M3Slider` | HSlider | 滑块 |
| `M3TextField` | LineEdit | 输入框（Filled / Outlined） |
| `M3ProgressIndicator` | Control | 线性 / 圆形进度，支持不确定动画 |
| `M3Divider` | Control | 分隔线（水平 / 垂直） |
| `M3Badge` | Label | 徽标 / 小红点 |
| `M3Tab` | Button | 单个标签页 |
| `M3TabBar` | HBoxContainer | 标签栏（互斥选中，`切换(索引)`） |
| `M3NavigationBar` | PanelContainer | 底部导航栏（自动生成按钮，`切换(索引)`） |
| `M3Tooltip` | PanelContainer | 提示气泡（`弹出()` / `收起()`） |
| `M3Ripple` | Control | 涟漪效果（按钮内部用） |

## 用法

组件通过 `class_name` 注册，**在编辑器里就能像普通节点一样添加**（节点类型里搜 M3）。
也可以用代码：

```gdscript
var 按钮 := M3Button.new()
按钮.text = "开始"
按钮.样式类型 = M3Button.按钮样式.TONAL
按钮.pressed.connect(_on_pressed)
add_child(按钮)
```

## 主题 / 配色

颜色令牌集中在 `M3Theme`（静态类，不需要 autoload）：

```gdscript
M3Theme.primary = Color(0, 0.349, 0.78)
M3Theme.应用种子(Color("0b57d0"))   # 按种子色派生整套令牌
M3Theme.scale = 1.5                 # 整套组件整体放大
```

## 和项目现有的 1920×1080 缩放

项目已经有「1920 渲染 + 窗口缩放」，所以 `M3ThemeManager.自动缩放` **默认关闭**，
避免双重缩放。想用它的缩放再打开即可。

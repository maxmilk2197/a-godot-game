# Godot 4 Material Design 3 / Material You 资源调研报告

- 调研对象：Godot 4（本项目使用 **4.7**）下的 Material Design 3 / Material You / 品牌级 UI 方案
- 调研目的：判断「网上是否有比我们自研 `addons/material_ui/` 更成熟、更好用的现成方案」
- 项目前提：**纯 GDScript**、**标准版 Godot（非 .NET/Mono）**、已自研一版 M3 组件（20 个 `.gd` + `M3Theme` 颜色令牌 + `M3ThemeManager` 自动加载，约 49 KB / 42 个文件）
- 报告日期：以调研时各来源显示的日期为准

---

## 0. 调研方法与可信度声明

### 0.1 本环境的网络限制（很重要）

| 目标 | 结果 |
|---|---|
| `github.com`（网页） | ❌ 不可达（DNS 解析到非公网 IP） |
| `raw.githubusercontent.com` | ❌ 不可达 |
| `api.github.com`（GitHub REST API） | ✅ **可用**（`Invoke-RestMethod` 可正常取到真实 JSON） |
| `cdn.jsdelivr.net/gh/<user>/<repo>@<ref>/<file>` | ✅ **可用**（可读取仓库内文件原文） |
| `godotengine.org` / 官方 Asset Library + REST API | ✅ 可用 |
| `store.godotengine.org`（新版官方 Asset Store） | ✅ 可用（页面可抓，搜索端点为 `/search/?query=`） |
| `docs.godotengine.org` | ✅ 可用 |
| `godotassetlibrary.com`（第三方镜像） | ❌ Cloudflare 403 |
| `web_search`（搜索引擎摘要 + 来源链接） | ✅ 可用 |

**因此：本报告对 `github.com` 仓库的结论并非「无法核实」** —— 凡是标注了 GitHub API / jsDelivr 一手数据的条目，都是通过 API 或镜像读取到的**仓库真实元数据与文件原文**（star 数、创建/推送时间、语言统计、`project.godot`、`.csproj`、README 原文）。其余无法通过任何可达渠道确认的内容，一律显式写「**未能核实**」并注明原因。本报告不编造任何版本号、star 数或日期。

### 0.2 官方 Asset Library API 的行为怪癖（影响检索结论的可信度）

实测（2026 年调研时）：

- 列表接口 `GET /asset-library/api/asset`：
  - **不带 `godot_version` 参数时不带 filter 只返回 63 条**（`pages=1`），分页失效；
  - **加上 `godot_version=4.7` 后分页恢复正常**（`max_results=500` 时 page0–6 返回 500/500/500/500/500/500/406，合计约 **3406 条**，`pages=7`）——这是取全量目录的可行方式；
  - `filter=` **只匹配标题中的完整单词**（大小写不敏感）：`filter=theme` 有结果，`filter=themes` 只有 1 条；`filter=md3`、`filter=materialyou`、`filter=figma`、`filter=ui kit` 均为 **0 条**；且 `filter` 的结果数还随 `godot_version` 变化（`theme` 不带版本只有 1 条，带 4.4 有 14 条，带 4.7 有 15 条）。
  - 结论：**「filter 返回 0 条」不能证明「不存在该资产」**；本报告的否定性结论基于**全量分页扫描 + 多关键词交叉检索 + 新版 Asset Store 搜索**三重验证。
- 详情接口 `GET /asset-library/api/asset/<id>` 字段比列表丰富得多，含 `browse_url`（仓库地址）、`issues_url`、`download_url`。注意两个反直觉字段：**`cost` 字段里装的是许可证**（如 `"MIT"`），**`author` 就是「submitted by user」**。

### 0.3 官方「新旧两个库」必须都查

官方博文 [Introducing the Godot Asset Store](https://godotengine.org/article/introducing-the-godot-asset-store/)（2026-05-22）明确：

- 旧 Asset Library「**should be considered deprecated, and will be set as a read-only repository in the near future**」，但因老版本引擎仍需要而继续运行；
- 官方**决定不自动迁移**旧库资产（需出版商建号、需逐作者授权、旧库不托管文件）；
- 新 store 使用 Godot 共享账号，**「will be fully integrated in Godot 4.7」**。

→ **两库内容大量不重合，只查一个会漏。** 本报告两边都扫过。

---

## 1. `rnewquist/godot_material3`（已核实，一手数据）

这是全网检索到的、**唯一**一个自称「完整 M3 设计系统」的 Godot 实现。信息来源：GitHub REST API + jsDelivr 文件原文。

| 项目 | 结论 |
|---|---|
| 链接 | https://github.com/rnewquist/godot_material3 |
| 实现语言 | **C#（100%）** —— GitHub 语言统计 `{"C#": 205431}`，即约 205 KB C# 代码 |
| 支持的 Godot 版本 | **4.6+**（README 徽章 `Godot-4.6+`；`project.godot` 中 `config/features=PackedStringArray("4.6", "C#", "GL Compatibility")`） |
| .NET 要求 | **.NET 8**（`Material3.csproj`：`<Project Sdk="Godot.NET.Sdk/4.6.2">` + `<TargetFramework>net8.0</TargetFramework>`；README 徽章 `.NET-8.0`） |
| 是否支持非 .NET 标准版 | ❌ **完全不支持**。全部组件是 `.cs`，项目特征含 `"C#"`，README 要求把 C# 文件加入 `.csproj`。Godot 只有 .NET 构建才带 C# 支持 |
| 最近维护 | 创建 **2026-05-25**，最后推送 **2026-07-09**（`dd7fe9d3 "Updated the files"`） |
| 活跃度 | **2 star / 0 fork / 0 watcher / 0 issue / 0 release / 无 tag**，全部历史**仅 6 次提交**，`archived=false`，MIT |
| 上架 Asset Library | ❌ 未上架（对 4.6 资产 API 全量分页扫描约 3363 条未见；`filter=material` 只有无关的 3D 材质工具） |
| 成熟度信号 | 仓库内有 `.gemini/`（AI 子代理开发日志目录）；`progress.md` 的 Phase 3–8 未勾选；仓库里存在**两套并行实现**（`addons/material_3_ui/` 只是骨架，真正的 15 个组件在根目录 `core/`+`components/`+`effects/`）；README 的安装步骤让你复制一个**仓库中并不存在的 `material-3/` 目录** |

**提供的内容**（README + 文件树逐一对应）：

- **15 个控件**：`M3Button`（Elevated / Filled / Tonal / Outlined / Text 五种变体）、`M3Switch`、`M3Checkbox`、`M3RadioButton`、`M3Slider`、`M3ProgressIndicator`（线性/圆形，确定/不确定）、`M3Card`、`M3Divider`、`M3Badge`、`M3TextField`（浮动标签 + 矢量描边挖空）、`M3NavigationBar`、`M3NavigationRail`、`M3NavigationDrawer`、`M3Tooltip`、`M3TabBar`/`M3Tab`
- **主题**：`core/M3Theme.cs` 定义约 22 个 M3 颜色角色 + 形状圆角令牌；`GenerateFromSeed(seedColor, isDark)` 由单一种子色经 **HSL 明度/饱和度偏移**推导整套明暗调色板（README 自述 "HSL seed-color palette generation"）—— 这是**近似实现，不是官方 HCT/CAM16 算法**
- **其他**：`M3ThemeManager` 自动加载单例、DPI 缩放引擎（96 DPI 基准、`clamp 1.0–3.0`、监听 `SizeChanged` 重排）、点击穿透浮层处理、涟漪动效、`M3Catalog.tscn` 演示场景、gdUnit4 测试（`gdUnit4.api 4.2.1`），以及仓库内约 80 MB 的 `.avi`/`.gif` 测试产物

**与我们的对比（值得注意）**：组件清单与我们的 `addons/material_ui/` **几乎一一对应**（我方为 M3Button/M3Card/M3Divider/M3Badge/M3ProgressIndicator/M3Switch/M3Checkbox/M3RadioButton/M3Slider/M3TextField/M3TabBar/M3Tooltip/M3NavigationBar + `core/M3Theme` + `effects/M3Ripple`；它多出 NavigationRail / NavigationDrawer，我们多出 M3Surface / M3ScrollStretch）。二者是否为独立演化、是否存在借鉴关系，**未能核实**，本报告不作推测。

**结论**：对我们这个纯 GDScript + 标准版 Godot 的项目 **❌ 完全不可直接用**（除非整体迁移到 .NET 构建）。而且即使是 C# 项目，它也只是 2 star、6 次提交、约 2 个月无提交、无 release 的个人早期项目，**成熟度并不比我们自研的那一版更高**。

---

## 2. 官方 Asset Library / Asset Store 全量扫描结果

### 2.1 最重要的否定性结论（三条）

1. **官方 Asset Library 中不存在任何 Material You / MD3 组件库。** `filter=md3`、`filter=materialyou`、`filter=material you`、`filter=material design 3` 全部 0 条；全量分页扫描（约 3406 条）标题中也没有 MD3 / Material You / MaterialYou 字样。
2. **没有任何资产自述实现了 Material You 动态取色（monet/dynamic color）**，也没有任何 **featured（官方推荐）级**的 UI 主题类资产 —— 扫描到的全部是 `community` 支持级别。
3. 新 Asset Store 的模糊搜索 `material design`（44 条）/ `material you`（126 条）结果**几乎全是 3D PBR 材质**，与 Material Design UI 无关。

### 2.2 与 Material / 主题 / UI 相关的主要条目

链接前缀 `AL:` = `https://godotengine.org/asset-library/asset/`

| 名称 | 链接 | 语言 | Godot | 维护 | 非 .NET 可用 | 类型 | 评价 |
|---|---|---|---|---|---|---|---|
| **Chromatica** | [AL 4659](https://godotengine.org/asset-library/asset/4659) / [repo](https://github.com/uxerror/chromatica) | **GDScript**（GitHub API 语言统计） | 标注 4.0，v1.0 | 创建 2026-01-09，最后推送 **2026-01-10**，MIT，7 star | ✅ | 编辑器插件（主题生成器） | **官方两库中唯一明确以 "Material Design principles" 自述的资产**。产出色彩令牌、排版、elevation、按钮/输入框等主题组件，可导出 Theme 资源。但：只有 7 star、**推送集中在 2 天内**、无 release，属于刚开坑就停下的项目 |
| **Widgets**（acgc99） | [AL 2028](https://godotengine.org/asset-library/asset/2028) / [repo](https://github.com/acgc99/Godot-Widgets) | **GDScript** | 4.1，v2.2.1 | **最后更新 2023-08-23（停更约 3 年）**，MIT | ✅ | 组件库 | 描述原文「A collection of widgets that are useful for GUIs. **Inspired by Material Design**」。含卡片/导航栏/弹出层/圆角图标按钮等，是**真·GDScript 组件库**，但没有 M3 色彩系统、没有 type variation、版本声明落后于 4.7 |
| **ThemeGen** | [AL 3299](https://godotengine.org/asset-library/asset/3299) / [repo](https://github.com/Inspiaaa/ThemeGen) | **GDScript**（资产页与仓库均明确） | 标注 4.0，v1.4.0 | **2026-05-02**，MIT，260 star | ✅ | 主题生成框架 | 用 GDScript **代码**生成 `Theme`：语义色、明暗双主题、样式复用/重组、保存时实时预览。**不是组件库**，但作为「主题层基础设施」是全生态中最成熟的选择 |
| **GDSS (Godot-CSS)** | [AL 4863](https://godotengine.org/asset-library/asset/4863) / [repo](https://github.com/cruglet/gdss) | **GDScript** | 4.6，v0.4.0 | **2026-06-17**，MIT，49 star | ✅ | 样式表系统 | 给 Godot 引入类 CSS 样式表（变量/状态/过渡/类/渐变 + 编辑器实时高亮与热重载）。作者自述 **early BETA**、且**不打算取代原生主题系统**，建议与原生主题并用；对 Tree/ItemList/TabBar 这类重复绘制同一 StyleBox 的节点，状态动画被禁用 |
| **Godot CSS Theme** | [AL 1038](https://godotengine.org/asset-library/asset/1038) / [repo](https://github.com/kuma-gee/godot-css-theme) | **GDScript** | 标注 4.1，v4.0 | **2025-12-19**，MIT，147 star | ✅ | 转换工具 | 描述仅一句「Converts CSS to Godot Themes」，把 CSS 子集编译成 Theme |
| **Reactive UI Toolkit — Godot** | [AL 5322](https://godotengine.org/asset-library/asset/5322) / [repo](https://github.com/reactive-ui-toolkit/ruitk-godot) | **纯 GDScript** | **4.7**，v0.14.0 | **2026-08-01** | ✅（技术上） | 应用架构框架 | React 范式：函数组件、hooks、fiber reconciler、router、`.guitkx` JSX 式标记编译成 `.gd`，带编辑器插件 + Fast Refresh + VS Code 工具。**但许可证是 Proprietary（专有，非开源）**，且它解决的是「状态与结构」而非「Material 视觉」，不含 M3 设计系统 |
| **UIFlow** | [AL 5377](https://godotengine.org/asset-library/asset/5377) / [repo](https://github.com/indieshade/uiflow) | GDScript | **4.6**，v1.0.0 | 2026（约 6 月创建、7 月推送），MIT | ✅ | 页面流程框架 | 栈式页面导航（push/pop/replace）、页面生命周期、转场预设、数据绑定、事件总线、Toast/Dialog 等可复用组件、手柄友好焦点导航。对视觉风格中立 |
| **Fancy StyleBoxes** | [AL 4407](https://godotengine.org/asset-library/asset/4407) | 未标注 | 4.4 | **2026-09-06** | 未标注（新增 StyleBox 资源，通常纯资源） | 资源类插件 | 介于 `StyleBoxFlat` 与 `StyleBoxTexture` 之间，支持圆角面板+背景纹理、多边框、**squircle/bevel/scoop/notch** 等角形、实验性材质。M3 的"圆角连续曲率"外观可借它 |
| **Live Palette** | [store](https://store.godotengine.org/asset/thiago-rocha/live-palette/) | 未核实 | 未核实 | v1.2.1 | 未核实 | 调色板工具 | 命名色板全局同步，覆盖 **theme overrides、StyleBoxes、Theme items、shader `source_color` uniform**，支持主题变体切换与 GIMP `.gpl` 导入导出 |
| **Theme Editor Extension** | [store](https://store.godotengine.org/asset/bakacandy/theme-editor-extension/) | 未核实 | **4.7** | 2026 | 未核实 | 编辑器增强 | 为 Godot 4.7 内置 Theme Editor 增加类型浏览器、预览层级、拾取器、主题项洞察、诊断 |
| **Material Design Icons for Godot（已弃用）** | [AL 2057](https://godotengine.org/asset-library/asset/2057) / [repo](https://github.com/rakugoteam/Godot-Material-Icons) | GDScript 资源 | 4.0，v2.0 | **仓库已 archived**（`archived=true`），推送 2024-12-14 | ✅ | 图标 | 提供 `MaterialIcon` / `MaterialButton` 节点、`MaterialIconsDB` 单例、`IconsFinder` 工具菜单。描述首句即「**Use Godot Font Icons instead!**」 |
| **Godot Icons Fonts** | [AL 3621](https://godotengine.org/asset-library/asset/3621) / [repo](https://github.com/rakugoteam/Godot-Icons-Fonts) | GDScript | **4.1+**，v1.2.5 | 2025-03-23，MIT，同作者（Jebedaia） | ✅ | 图标字体 | 上面那个弃用插件的**官方指定后继**。`FontIcon` / `FontIconButton` / `FontIconCheckButton` 节点 + `IconsFonts` 单例 + `IconsFonts.parse_text("[icon:name]")`，字体源为 Templarian Material Design Icons。**导出需在 include files 里加 `*.json`** |
| **Material Icons Importer** | [AL 4619](https://godotengine.org/asset-library/asset/4619) / [repo](https://github.com/mich-gamedev/godot-material-icons-importer) | GDScript | **4.5**，v1.0.0 | 2025-12-30，MIT | ✅ | 图标导入 | 右键目录导入 Google Material Icons 为**纹理**，支持 Filled/Outlined/Sharp/Round/Two-tone，导入后无网络依赖（得到 `Texture2D`，不是图标字体节点） |

### 2.3 其他扫描到但不对口的条目（避免重复劳动）

- **纯主题 `.tres` 包**：CS 1.6 Theme（[AL 4803](https://godotengine.org/asset-library/asset/4803)）、Windows 95 UI Theme（[AL 1672](https://godotengine.org/asset-library/asset/1672)）、Main Menu Multi-Theme（[AL 4258](https://godotengine.org/asset-library/asset/4258)）、Meta Horizon OS UI Kit（[AL 4009](https://godotengine.org/asset-library/asset/4009)，自述「only visuals, no functionality! This is only a theme」）。**没有任何 Material / Material You 风格的无脚本成套主题包。**
- **编辑器主题工具**（与我们游戏内 UI 无关）：Editor Theme Explorer（[AL 2353](https://godotengine.org/asset-library/asset/2353)，YuriSizov）、Theme Switcher（[AL 3013](https://godotengine.org/asset-library/asset/3013)）、WPGTK Theme（[AL 3630](https://godotengine.org/asset-library/asset/3630)）。
- **图标/图标字体**：Nerd Fonts plugin（AL 4644，自述含 10,764 图标/17 图标集，明确列出 Material Design）、Godot Expo Vector Icons（AL 4031，含 MaterialIcons 等 15 套）、FontAwesome 6（AL 2908）、Lucide icons（AL 5047，**首次运行需从 GitHub 拉取** → 本环境与离线导出的风险点）。
- **注意区分**：`Icon Explorer`（AL 2511）、`Icon Browser`（AL 4495）、`@icons`（AL 5302）、`plenticons`（AL 3660）、`Godot Easy Icons`（AL 5317）都是**编辑器节点图标**或图标浏览工具，不是 UI 图标库。

---

## 3. 纯主题类方案（只提供 Theme / `.tres`，不带脚本）

**已核实事实（Godot 官方文档）**：`Theme` 是 `Resource`，主题条目（theme item）只有 6 种数据类型 —— **Color / Constant / Font / Font size / Icon / StyleBox**。因此**纯主题完全可以是零脚本的 `.tres` 文件**，只靠项目设置 `GUI > Theme > Custom` 或某个 Control 的 `theme` 属性级联生效。来源：[Introduction to GUI skinning](https://docs.godotengine.org/en/stable/tutorials/ui/gui_skinning.html)

**更关键的一条**：主题**类型变体（theme type variations）**允许一个类型继承基础类型（如 `GrayButton` 继承 `Button`），覆盖部分条目并补齐基础类型未定义的条目，**且可以链式继承**；在 Inspector 的 `Theme Type Variation` 属性上应用。来源：[Theme type variations](https://docs.godotengine.org/en/stable/tutorials/ui/gui_theme_type_variations.html)

→ **这意味着 Material 的 Filled / Tonal / Outlined / Text 四种按钮变体，完全可以靠「纯主题 + type variations」实现，一行脚本都不需要。** 这对我们「纯 GDScript」的约束不构成任何障碍，反而说明**组件的外观层不该由脚本硬编码**。

**两条实用提示**：

- 编辑器 Theme Editor 的 **Manage Theme Items → Import Items** 可以**从默认主题、编辑器主题或另一个自定义主题导入 theme items**，并可选择是否带数据（不带数据则生成空模板）。来源：[Using the theme editor](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html)。→ 可以从 Godot 编辑器主题快速起盘，省掉大量 StyleBox 手搓工作。
- 仓库中另有两个可用插件（未上架官方库，仅 GitHub）：[Themey](https://github.com/wadlo/Themey)（GDScript，39 star，推送 2025-02-09，提供 clashy/spacey 两套 `.tres` 主题包 + `AdjustLightness.gdshader`）、[gdstyle](https://godotengine.org/asset-library/asset/5202)（AL 5202，4.3）。

---

## 4. 其他 GDScript 品牌级 / 通用 UI 组件库（非 Material）

| 名称 | 链接 | 语言 | Godot | 维护 | 非 .NET | 主要优点 | 主要缺点 | 我们能直接用吗 |
|---|---|---|---|---|---|---|---|---|
| **godot_ui_components**（MrEliptik） | [repo](https://github.com/MrEliptik/godot_ui_components) | GDScript | 4.x | 推送 2024-04-27，**774 star** | ✅ | star 最高的 Godot UI 组件参考集 | 是「UI 设计实现合集」而非可安装 addon；**停更** | ⚠️ 仅作视觉/交互参考 |
| **goduz** | [repo](https://github.com/crsolver/goduz) | GDScript | 4.x | 推送 2024-01-05，145 star | ✅ | 声明「面向 Godot 4 的 UI 构建库」 | 停更约 2 年 | ⚠️ 未实测 |
| **godot-desktop-themes** | [repo](https://github.com/violinbg/godot-desktop-themes) | GDScript | 未核实 | 推送 2024-12-09，281 star | ✅ | 面向桌面应用外观的主题集 | 未核实是否为 4.x；风格非 Material | ⚠️ 参考 |
| **godot-ui-component-library** | [AL 2395](https://godotengine.org/asset-library/asset/2395) / [repo](https://github.com/Bloodyaugust/godot-ui-component-library) | GDScript | 4.2 | 推送 2024-02-05，18 star | ✅ | 组件「完全可主题化」 | **只有 SingleSelect / SingleSelectSearch 两个组件** | ❌ 覆盖率太低 |
| **UI Widget** | [AL 4245](https://godotengine.org/asset-library/asset/4245) | 未标注 | 4.4 | **2026-07-04** | 未标注 | 常用 UI 元素 + 半自动设置面板 | 非 Material 设计语言 | ❌ 不对口 |
| **Extra GUI Controls** | [AL 1922](https://godotengine.org/asset-library/asset/1922) | 未标注 | 4.0 | 2025-04-26 | 未标注 | 插值 Box/Flow/Free 容器、Radial Container 等 | 非设计系统 | ⚠️ 布局补充 |
| **godot-reusable-ui-components** | [repo](https://github.com/Dodoveloper/godot-reusable-ui-components) | GDScript | 4.x | 创建 2026-09-01，37 star | ✅ | 通用可复用组件与抽象基类 | 极新（创建仅数日）、未成熟 | ⚠️ 观望 |
| **ViewGD** | [repo](https://github.com/Boxxfish/ViewGD) | GDScript | 4.x | 推送 2025-07-30，30 star | ✅ | Vue 式响应式 UI | 仓库自述「**Does not work with the latest version of Godot**」 | ❌ 明确不兼容新版 |
| **dockable-container** | [repo](https://github.com/gilzoide/godot-dockable-container) | GDScript | 4.4+ | tag 至 1.1.1 | ✅ | 成熟的停靠/分屏面板 | 只管布局，无视觉主题；资产库对应条目 [AL 916](https://godotengine.org/asset-library/asset/916) 还是 Godot 3.4 的旧条目 | ⚠️ 仅桌面式布局需要时 |

**另有两个同名易混淆项，已排除**：

- [UkonnRa/Godot-Material-UI-Design](https://github.com/UkonnRa/Godot-Material-UI-Design)：GDScript，**0 star，无 README（API 返回 404）、无 license、仅 1 天活动（2024-12-20 ~ 12-21）** → 空壳，无法评估。
- [Maurehago/lowmat](https://github.com/Maurehago/lowmat)：GDScript，0 star，README 全文仅两行「# lowmat / Low Material Design for Godot Game Engine」，最后推送 **2022-03-06** → Godot 3 时代遗物。
- [pattlebass/Godot-Material3-Overscroll](https://github.com/pattlebass/Godot-Material3-Overscroll)：GDScript，3 star，推送 2022-11-07 → 只做 Android 12 过度滚动效果，不是组件库。
- **Lorien**（mbrlabs/Lorien）常被误当作 UI 库，实际是**用 Godot 做的无限画布白板应用**，不可复用。

---

## 5. 周边工具：Figma / Material Theme Builder → Godot Theme

### 5.1 Material Theme Builder 确实存在，但**不能导出 Godot**

- 仓库：[material-foundation/material-theme-builder](https://github.com/material-foundation/material-theme-builder)（Apache-2.0）。线上版：https://material-foundation.github.io/material-theme-builder/ 、 https://m3.material.io/theme-builder/ ，另有 Figma 社区插件。
- **导出格式（从线上 bundle `main.dart.js` 直接核实，非推测）**：`Material Theme (JSON)`、`Android Views (XML)`（含 `colors.xml` / `values-night`）、`Jetpack Compose (Theme.kt)`、`Web (CSS)`、`M3 Figma Design Kit`。
- 该 bundle 中**不出现 `Godot` 字样** → **MTB 无法导出 Godot Theme**。（其 GitHub 仓库的最近推送情况因元数据源限制**未能核实**。）

### 5.2 Material 3 的 token 模型（用于我们自己实现时对齐规范）

已核实来源：[Flutter `ColorScheme` 文档](https://api.flutter.dev/flutter/material/ColorScheme-class.html)（其依据 m3.material.io 的 color roles 规范）：

- 用 **color roles + tokens** 表达，`ColorScheme` 共 **45 个颜色**；
- `primary` / `secondary` / `tertiary` 三组，每组含 `-Container`、`-Fixed`、`-FixedDim`、`on-*` 变体；
- surface 采用 **tone-based surfaces 与 surface containers**：`surfaceBright`、`surfaceDim`、`surfaceContainerLowest/Low/Container/High/Highest` —— **取代了旧的「按海拔叠加半透明 tint」模型**；
- `on-*` 角色与对应色的对比度应 **≥ 4.5:1**；
- 另有 `error` / `outline` / `outlineVariant` / `shadow` / `scrim` / `inverse*`。
- **状态层（state layer）不透明度**（已核实）：**hover 8%、focus 10%、pressed 10%、dragged 16%**。
- Material You 的**动态取色算法参考实现**：[material-foundation/material-color-utilities](https://github.com/material-foundation/material-color-utilities)（**Apache-2.0**，2265 star，推送 2026-08-21，官方支持 TypeScript / Java / Swift / Kotlin / Dart / C++）。**没有 GDScript 版本**；虽然 Apache-2.0 允许移植，但 HCT/CAM16 的完整移植工作量不小。
- **等级 0/1/3/6/8/12dp 的海拔分级未能核实**（m3.material.io 为 JS 渲染，抓取仅得外壳）。

### 5.3 Figma / Design Tokens → Godot

| 工具 | 链接 | 语言 | 结论 |
|---|---|---|---|
| figma-godot-exporter | [repo](https://github.com/morganwalkup/figma-godot-exporter) | JavaScript（Figma 插件） | 28 star，推送 2025-01-17。**导出的是节点/资源集合，不是 Theme 资源** |
| figma-to-godot-experiment | [repo](https://github.com/mightymochi/figma-to-godot-experiment) | GDScript | 87 star，推送 2024-12-03，自述「experimental Figma json importer」，GPL-3.0 |
| penpot-to-godot | [repo](https://github.com/mightymochi/penpot-to-godot) | 未核实 | 20 star，同作者 |
| DTCG 设计令牌规范 | [designtokens.org/technical-reports](https://www.designtokens.org/technical-reports/) | — | 稳定版 **2025.10** 已于 2025-10-28 发布 |

**结论（已核实）**：**不存在能把 Figma 设计系统 / Material 主题 / DTCG 令牌 JSON 直接转成 Godot `Theme(.tres)` 的现成工具。** 这一段胶水（M3 JSON/CSS → Godot theme items）**必须自研** —— 而这恰好是 ThemeGen 这类「用 GDScript 代码生成 Theme」框架的强项。

---

## 6. Godot 官方文档中有价值的几点（含 4.7 兼容性判定）

- ⚠️ `/tutorials/ui/gui_theme.html` 返回 **404**，正确页面是 [gui_skinning.html](https://docs.godotengine.org/en/stable/tutorials/ui/gui_skinning.html)。
- **主题查找顺序**：本地 override → 自身及祖先 Control 的 `theme` 属性 → 项目主题（`GUI > Theme > Custom`）→ 默认主题。主题沿 Control 树**级联**。focus stylebox 是**叠加绘制**的，应设计成描边/半透明，否则会盖住底色。
- **4.7 对主题系统无破坏性改动**（[4.6→4.7 升级文档](https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html)）：GUI nodes 段只有 `RichTextLabel.add_image/update_image` 的参数类型变更、`Control.accessibility_live` 类型变更；**Theme / type variation / theme editor 均无破坏性变更**。→ 现有的 4.x 主题方案可放心沿用。
- ⚠️ 但 **Import 段 `ResourceImporterDynamicFont.hinting` 默认值从 1 变为 3**，会影响字体渲染观感 —— 对以排版质感为卖点的 M3 风格 UI 值得实测。
- [custom_gui_controls.html](https://docs.godotengine.org/en/stable/tutorials/ui/custom_gui_controls.html) 页首明确标注「**内容尚未针对 Godot 4.7 更新，可能过时**」。
- **4.6 起新增** [creating_applications.html](https://docs.godotengine.org/en/stable/tutorials/ui/creating_applications.html)：把 Godot 当 Electron/Qt 替代做非游戏应用（多窗口 `Window` 节点、`min_size`/`max_size`、原生文件对话框 `use_native_dialog`、系统托盘 `StatusIndicator`）。对「品牌级应用 UI」的定位有参考价值。
- **引擎层面也没有原生 Material 支持**：[godot-proposals #9210「Add support for calculating a Material UI palette from a given color」](https://github.com/godotengine/godot-proposals/issues/9210) 于 **2024-02-29** 提出，状态至今仍是 **open**（6 条评论，未关闭、未实现）。

---

## 7. 推荐排序

### 7.1 直接可用（对我们的纯 GDScript + 标准版 Godot 4.7 无阻碍）

| 排名 | 方案 | 用途 | 理由 |
|---|---|---|---|
| 🥇 **1** | **官方机制：Theme + theme type variations** | 承载 Material 的 Filled/Tonal/Outlined/Text 等变体 | 零脚本、官方支持、可链式继承、4.7 无破坏性变更。**我们当前把变体做进脚本里，是把问题放错了层** |
| 🥈 **2** | **ThemeGen**（[AL 3299](https://godotengine.org/asset-library/asset/3299)，GDScript，MIT，260 star，2026-05 仍活跃） | 主题生成层：语义色、明暗双主题、样式复用、保存时实时预览 | 生态里最成熟的「代码生成 Theme」框架；GDScript；可把 M3 token（甚至 MTB 导出的 JSON）映射成 Theme —— **正好补上第 5.3 节缺失的胶水层** |
| 🥉 **3** | **Godot Icons Fonts**（[AL 3621](https://godotengine.org/asset-library/asset/3621)，MIT，4.1+） | Material Design Icons 图标 | 被弃用插件官方指定的后继；节点化用法；**注意导出需 include `*.json`** |
| 4 | **Material Icons Importer**（[AL 4619](https://godotengine.org/asset-library/asset/4619)，4.5） | 如只想拿 `Texture2D` 图标 | 导入后零运行时依赖，比图标字体更可控 |
| 5 | **Fancy StyleBoxes**（[AL 4407](https://godotengine.org/asset-library/asset/4407)）/ **Live Palette**（新 store） | 角形（squircle）与全局命名色板 | 补足原生 StyleBoxFlat 与主题改色的短板；纯资源/工具层，不影响架构 |
| 6 | **Chromatica**（[AL 4659](https://godotengine.org/asset-library/asset/4659)，GDScript） | 参考它的色彩系统/排版/elevation 组织方式 | 唯一自述按 Material Design 原则做的资产，但只有 7 star、两天热度，**建议只读代码取思路，不引入依赖** |

### 7.2 有条件可用（需先验证或许可确认）

| 方案 | 条件 |
|---|---|
| **GDSS (Godot-CSS)** [AL 4863](https://godotengine.org/asset-library/asset/4863) | 自述 early BETA；对 Tree/ItemList/TabBar 的状态动画被禁用；作者建议与原生主题并用。**建议实验，不要作为主干** |
| **UIFlow** [AL 5377](https://godotengine.org/asset-library/asset/5377) | Godot 4.6 / MIT / 2026 年活跃，做页面栈与转场很顺手；但它是流程框架，不提供视觉。若我们缺页面导航可以引入 |
| **Godot CSS Theme** [AL 1038](https://godotengine.org/asset-library/asset/1038) | 147 star、2025-12 更新；若团队更熟 CSS，可以把 M3 token 用 CSS 表达再编译成 Theme。**需在 4.7 实测** |
| **Reactive UI Toolkit** [AL 5322](https://godotengine.org/asset-library/asset/5322) | 技术上是纯 GDScript 且明确支持 4.7，但**许可证是 Proprietary（专有）**，商用/闭源发行前必须先确认授权条款 |
| **Widgets (acgc99)** [AL 2028](https://godotengine.org/asset-library/asset/2028) | 真·GDScript 组件库且自称 Inspired by Material Design，但**停更近 3 年**、标注 4.1，需实测 4.7 兼容 |
| **godot-desktop-themes**、**godot_ui_components**、**goduz** | 仅作视觉与交互参考；均非活跃维护的可安装设计系统 |

### 7.3 不能用

| 方案 | 为什么不能用 |
|---|---|
| **rnewquist/godot_material3** | **要求 Godot 4.6+ 的 .NET 构建 + .NET 8**，全部是 C#；我们用的是标准版 Godot，**根本无法加载**。且自身只有 2 star / 6 次提交 / 无 release / 约 2 个月无提交，成熟度不高于我们自研版本 |
| **ViewGD** | 仓库自述不兼容最新 Godot |
| **Lorien** | 不是 UI 库，是用 Godot 做的白板应用 |
| **lowmat / UkonnRa/Godot-Material-UI-Design / Godot-Material3-Overscroll** | 分别停更于 2022 / 空壳无 README / 只做过度滚动效果 |
| **Material Theme Builder 直接导出** | **不支持 Godot 导出目标**（只有 JSON / XML / Compose / CSS / Figma Kit）。它只能作为**配色来源**，中间需要自研转换层 |
| **Figma → Godot Theme 的现成工具** | **不存在**（已核实）。figma-godot-exporter 等导出的是节点/资源，不是 Theme |

---

## 8. 结论：有没有比我们自研更好的选择？

**没有可以直接替换我们自研 `addons/material_ui/` 的现成方案 —— 但这不等于「自研就是最优解」，真正的问题不在组件层，而在主题层。**

三点理由：

1. **唯一对标的 M3 实现（rnewquist/godot_material3）对我们完全不可用。** 它要求 Godot 4.6+ 的 **.NET 构建 + .NET 8**，全部代码是 C#，标准版 Godot 连脚本都加载不了；而且它只有 2 star、6 次提交、0 release、约 2 个月没有提交，README 与仓库结构还对不上（安装路径写的是仓库里不存在的目录）。也就是说，**它在成熟度上并不比我们已经写出来的那一版更好**，唯一值得借鉴的是它多做了 NavigationRail / NavigationDrawer 两个组件、以及 `GenerateFromSeed(seedColor, isDark)` 这个 API 形状（虽然它是用 HSL 近似，而不是官方 HCT）。

2. **官方两个资产库（旧 Asset Library + 新 Asset Store）里根本不存在 Material Design 3 / Material You 组件库。** `md3` / `materialyou` / `material you` 的检索均为 0 条；也没有任何 featured 级的 UI 主题资产；引擎层面的相关提案（godot-proposals #9210，按给定颜色计算 Material 调色板）自 2024-02 至今仍是 open。生态里唯一自述按 Material Design 原则做的 Chromatica 只有 7 star、两天热度就停了。**所以"自研组件"这条路本身没有被别人走通过，我们不是在做重复劳动。**

3. **真正可被替换、而且应该被替换的是"主题生成与变体表达"这一层。** 官方文档明确：`Theme` 是纯 Resource，**type variations** 可以无脚本实现 GrayButton/Filled/Tonal/Outlined 这类变体并链式继承，4.7 对主题系统也没有破坏性改动；而 ThemeGen（GDScript，MIT，260 star，2026-05 仍活跃）已经把"用 GDScript 代码生成 Theme、语义色、明暗双主题、保存时实时预览"做得比我们手写 `M3Theme` 更系统。与此同时，**Material Theme Builder 只能导出 JSON/XML/Compose/CSS，绝不能导出 Godot Theme**，而 Figma/设计令牌 → Godot Theme 的转换工具**根本不存在** —— 这块胶水必须自研，且用 ThemeGen 来写是最省力的路径。另外状态层不透明度（hover 8% / focus 10% / pressed 10% / dragged 16%）、surface container 那套 token 命名，也都应该对齐官方规范而不是自己发明。

**因此建议**：**保留自研的组件层（`addons/material_ui/` 的 20 个组件是我们真正的资产，市面上没有替代品），但把"配色/令牌/变体"从脚本里挪到 Theme 层** —— 用 ThemeGen 或自研生成器产出 `.tres`，用 type variations 表达按钮变体，再从 Material Theme Builder 的 JSON 导出对齐 M3 色彩角色与状态层不透明度；图标换成 Godot Icons Fonts（注意导出 include `*.json`）。这样我们既不放弃已有的 GDScript 组件，又能一次性拿到"M3 规范正确性 + 主题可维护性"这两个自研版本目前最弱的部分。

---

## 9. 来源链接汇总

### 9.1 项目仓库（通过 GitHub REST API / jsDelivr 读取一手数据）

- rnewquist/godot_material3 — https://github.com/rnewquist/godot_material3
  - 元数据：https://api.github.com/repos/rnewquist/godot_material3
  - README 原文：https://cdn.jsdelivr.net/gh/rnewquist/godot_material3@main/README.md
  - `project.godot`：https://cdn.jsdelivr.net/gh/rnewquist/godot_material3@main/project.godot
  - `Material3.csproj`：https://cdn.jsdelivr.net/gh/rnewquist/godot_material3@main/Material3.csproj
- uxerror/chromatica — https://github.com/uxerror/chromatica
- Inspiaaa/ThemeGen — https://github.com/Inspiaaa/ThemeGen
- cruglet/gdss — https://github.com/cruglet/gdss
- kuma-gee/godot-css-theme — https://github.com/kuma-gee/godot-css-theme
- acgc99/Godot-Widgets — https://github.com/acgc99/Godot-Widgets
- reactive-ui-toolkit/ruitk-godot — https://github.com/reactive-ui-toolkit/ruitk-godot
- indieshade/uiflow — https://github.com/indieshade/uiflow
- rakugoteam/Godot-Material-Icons — https://github.com/rakugoteam/Godot-Material-Icons
- rakugoteam/Godot-Icons-Fonts — https://github.com/rakugoteam/Godot-Icons-Fonts
- mich-gamedev/godot-material-icons-importer — https://github.com/mich-gamedev/godot-material-icons-importer
- morganwalkup/figma-godot-exporter — https://github.com/morganwalkup/figma-godot-exporter
- mightymochi/figma-to-godot-experiment — https://github.com/mightymochi/figma-to-godot-experiment
- material-foundation/material-theme-builder — https://github.com/material-foundation/material-theme-builder
- material-foundation/material-color-utilities — https://github.com/material-foundation/material-color-utilities
- wadlo/Themey — https://github.com/wadlo/Themey
- crsolver/goduz — https://github.com/crsolver/goduz
- MrEliptik/godot_ui_components — https://github.com/MrEliptik/godot_ui_components
- violinbg/godot-desktop-themes — https://github.com/violinbg/godot-desktop-themes
- Bloodyaugust/godot-ui-component-library — https://github.com/Bloodyaugust/godot-ui-component-library
- Boxxfish/ViewGD — https://github.com/Boxxfish/ViewGD
- gilzoide/godot-dockable-container — https://github.com/gilzoide/godot-dockable-container
- Maurehago/lowmat — https://github.com/Maurehago/lowmat
- UkonnRa/Godot-Material-UI-Design — https://github.com/UkonnRa/Godot-Material-UI-Design
- pattlebass/Godot-Material3-Overscroll — https://github.com/pattlebass/Godot-Material3-Overscroll

### 9.2 Godot 官方资产库 / 商店

- 资产库首页 — https://godotengine.org/asset-library/asset
- 资产库 API — https://godotengine.org/asset-library/api/asset
- 新版官方 Asset Store（beta） — https://store.godotengine.org/
- 官方博文《Introducing the Godot Asset Store》 — https://godotengine.org/article/introducing-the-godot-asset-store/
- 具体资产页（`https://godotengine.org/asset-library/asset/<id>`）：Chromatica **4659**、Widgets **2028**、ThemeGen **3299**、GDSS **4863**、Godot CSS Theme **1038**、Reactive UI Toolkit **5322**、UIFlow **5377**、Fancy StyleBoxes **4407**、Material Design Icons for Godot (Deprecated) **2057**、Godot Icons Fonts **3621**、Material Icons Importer **4619**、Godot UI Component Library **2395**、UI Widget **4245**、Extra GUI Controls **1922**、Editor Theme Explorer **2353**、Custom Theme Overrides **2091**、Main Menu Multi-Theme **4258**、CS 1.6 Theme **4803**、Windows 95 UI Theme **1672**、Meta Horizon OS UI Kit **4009**、Theme Switcher **3013**、WPGTK Theme **3630**、gdstyle **5202**、Godot Expo Vector Icons **4031**、Lucide icons **5047**
- 新 Asset Store 条目：EZ-Theme `store.godotengine.org/asset/inanimate-ink/ez-theme/`、Theme Editor Extension `store.godotengine.org/asset/bakacandy/theme-editor-extension/`、Live Palette `store.godotengine.org/asset/thiago-rocha/live-palette/`

### 9.3 Godot 官方文档

- Introduction to GUI skinning — https://docs.godotengine.org/en/stable/tutorials/ui/gui_skinning.html
- Theme type variations — https://docs.godotengine.org/en/stable/tutorials/ui/gui_theme_type_variations.html
- Using the theme editor — https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html
- Custom GUI controls（页首标注未针对 4.7 更新） — https://docs.godotengine.org/en/stable/tutorials/ui/custom_gui_controls.html
- Creating applications — https://docs.godotengine.org/en/stable/tutorials/ui/creating_applications.html
- Upgrading from Godot 4.6 to 4.7 — https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html
- （注意 `/tutorials/ui/gui_theme.html` 已 404）

### 9.4 Material 3 规范与设计工具

- Material Theme Builder 在线版 — https://material-foundation.github.io/material-theme-builder/ 、 https://m3.material.io/theme-builder/
- Material Theme Builder Figma 插件 — https://www.figma.com/community/plugin/1034969338659738588/material-theme-builder
- Flutter `ColorScheme`（M3 color roles / 45 色 / surface containers） — https://api.flutter.dev/flutter/material/ColorScheme-class.html
- 状态层不透明度（hover 8% / focus 10% / pressed 10% / dragged 16%） — https://pub.dev/documentation/material_3_expressive/latest/foundations_interaction_m3e_state_layer/M3EStateOpacity-class.html
- Design Tokens 技术报告（DTCG 2025.10） — https://www.designtokens.org/technical-reports/
- Godot 提案：按给定颜色计算 Material UI 调色板（open） — https://github.com/godotengine/godot-proposals/issues/9210

---

## 10. 未能核实清单（诚实标注）

1. `m3.material.io` 正文为 JS 渲染，本环境抓取只能得到外壳 → **M3 海拔分级 0/1/3/6/8/12dp 的具体数值未能核实**；M3 token 模型结论是从 Flutter 官方 `ColorScheme` 文档与已核实的令牌文档间接得到的。
2. Google 官方字体文档（`developers.google.com/fonts/docs/material_symbols`）抓取失败 → **是否存在 Godot 专用的 Material Symbols addon 未能核实**。
3. `material-foundation/material-theme-builder` 的最近推送日期、star 数、release 情况**未能核实**（第三方索引站点不可达/需付费）；其**导出格式清单**已从线上 bundle 核实。
4. 新版 Asset Store 的资产**版本下拉、兼容 Godot 版本、许可证**未逐一核实（页面部分为 JS 渲染）；搜索结果计数（`theme` 461 / `ui` 873 等）是**模糊排名结果数，不等于资产数**。
5. 部分资产的**实现语言在资产页未标注**（如 Fancy StyleBoxes、UI Widget、Live Palette、Theme Editor Extension），本报告未猜测；标「未标注」处即为此意。
6. 官方资产库 API 的 `total` 字段始终为空 → 报告中的 **~3406 条 / 419 条**是分页推算值，不是服务端声明的总数。
7. 各 third-party 组件库是否能在 **Godot 4.7 上实际运行**均**未经实测**（本报告只核实了版本声明、活跃度与许可证）。
8. **无法从公开信息判断 rnewquist/godot_material3 与本项目 `addons/material_ui/` 组件清单高度重合的原因**，不作任何推测。

# Swap Bros 联机分支

本分支 fork 自 [alexneargarder/BroforceMods](https://github.com/alexneargarder/BroforceMods)，独立仓库为 [GJKen/SwapBros](https://github.com/GJKen/SwapBros)，沿用 GPL-3.0。原作者、上游说明和其它插件历史均保留，当前只维护 `Swap Bros Mod/`。

在 Broforce-Mods 中以 `SwapBrosMultiplayer` 子模块接入，结构与 BroMakerMultiplayer 一致。本地使用 sparse checkout 显示 `Swap Bros Mod` 和共享 `Scripts`；完整上游历史仍可通过 Git 访问。

## 当前修复

2.1.6 修复加入方的快捷键和菜单换人。2.1.7 修正其菜单回归：`Local Player 1 Options` 对应本机第一个已加入的玩家，即使实际控制器编号不是 0；键位编辑和读取使用该玩家的真实 `controllerNum`，选角状态仍按联机 `playerNum` 保存，换人只操作本机拥有的玩家。保留 `Main.GetSelectedBroHeroType(int)`，兼容当前 CustomMapMultiplayer 的反射调用。

进度、手动验收和清理记录见 [加入方无法切换角色](Swap%20Bros%20Mod/issues/2026-11-09-client-swap.md)。

## 构建与部署

保留上游 `.csproj` / `.sln` 构建入口。当前机器没有 .NET SDK/MSBuild，使用 `Swap Bros Mod/Build.ps1` 调用 Roslyn 4.8 的 .NET Framework 编译器，目标仍为 .NET 3.5。编译器可从 NuGet 的 `Microsoft.Net.Compilers.Toolset` 4.8.0 包获取，放入被忽略的 `Swap Bros Mod/bin/tooling/`。

```powershell
& '.\Swap Bros Mod\Build.ps1' `
  -CompilerPath '.\Swap Bros Mod\bin\tooling\roslyn\tasks\net472\csc.exe' `
  -BroforcePath 'E:\SteamLibrary\steamapps\common\Broforce' `
  -UmmPath 'E:\SteamLibrary\steamapps\common\Broforce\r2mod\Broforce\profiles\Broforce\UMM'
```

构建脚本只编译，产物在 `Swap Bros Mod/bin/Release/Swap Bros Mod.dll`。部署前关闭并确认两端游戏退出；把 DLL 和 `Swap Bros Mod/Swap Bros Mod/_ModContent/Info.json` 覆盖到已有的 `UMM/Mods/AlexN-Swap_Bros/Swap Bros Mod/`，保留设置和 RocketLib 键位。不要同时安装第二份 Swap Bros。

用户已确认联机中房主、加入方切换自定义角色均正常。已按用户要求创建英文 [上游 PR #6](https://github.com/alexneargarder/BroforceMods/pull/6)，仅推送三个相关源码文件；本地版本号、构建入口和 issue 不推送。[本地 PR 独立记录](Swap%20Bros%20Mod/docs/publication/2026-11-09-client-swap-pr/README.md)保存范围、验收与回执。2026-11-09 05:03 已完成任务专用工具、响应文件、备份和 PR 编译目录的清理，正式 DLL、源码和必要文档证据保留。

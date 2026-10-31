# ClassIn 自动登录工具（Windows）

双击一键启动 ClassIn 并自动填入账号密码、按回车登录。零额外依赖，仅使用 Windows 系统自带的 PowerShell。

## 功能
- 双击 `.bat` 自动启动 ClassIn 客户端并登录
- 双输入模式：**键盘模式**（默认）/ **坐标模式**（兜底，100% 可靠）
- 凭据存本地文件，不依赖任何第三方软件

## 环境要求
- Windows 系统
- 已安装 ClassIn 桌面客户端
- 系统自带 PowerShell（无需安装）

## 使用方法

### 1. 首次配置
1. 把整个 `classin-auto-login` 文件夹拷到 Windows 机器（建议放非云同步目录，例如 `D:\Tools\classin-auto-login\`）。
2. 复制 `classin_credentials.txt.example` 为 `classin_credentials.txt`，填入你自己的账号和密码并保存。
3. 双击「运行ClassIn自动登录.bat」。

### 2. 如果账号密码没填进去（焦点问题）
ClassIn 是自研客户端，键盘模拟不一定能准确落到输入框。改用坐标模式：
1. 手动打开 ClassIn 登录窗口，放在不被遮挡的位置。
2. 双击「获取坐标.bat」。
3. 按提示把鼠标移到【账号输入框】按 Enter，再移到【密码输入框】按 Enter，坐标会自动写入 `classin_config.txt`。
4. 之后每次双击「运行ClassIn自动登录.bat」即用坐标模式登录。

### 3. ClassIn 路径不对
若双击后提示“找不到 ClassIn”，说明 `classin_path` 不对。打开 `classin_config.txt`，把 `classin_path` 改成你机器上 `ClassIn.exe` 的真实路径（可在开始菜单右键“打开文件位置”查看）。

## 文件说明
| 文件 | 作用 |
|------|------|
| `运行ClassIn自动登录.bat` | 双击启动器，运行主脚本 |
| `classin_auto_login.ps1` | 主脚本：启动 ClassIn、填表、回车 |
| `获取坐标.bat` / `capture_coords.ps1` | 采集账号框 / 密码框屏幕坐标 |
| `classin_config.txt` | 配置（路径、超时、坐标） |
| `classin_credentials.txt.example` | 凭据模板（复制为 `.txt` 后填真实账号密码） |
| `.gitignore` | 忽略真实凭据文件，防止密码被提交 |

## 安全提醒
- **`classin_credentials.txt` 存的是明文密码，仅限个人本机使用，切勿放入 OneDrive / 百度网盘等任何云同步或共享目录。**
- 推荐用 `icacls` 收紧文件权限（在文件夹里 Shift+右键“在此处打开 PowerShell”，执行）：
  ```
  icacls "classin_credentials.txt" /inheritance:r /grant:r "%USERNAME%:R"
  ```
- 更安全的做法是改用 Windows 凭据管理器（需改写脚本）。

## 免责声明
本工具仅供个人便利化使用，使用风险自担。请遵守 ClassIn 相关服务条款。

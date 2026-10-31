# ============================================================
# ClassIn 自动登录脚本 (Windows)
# 用法：双击「运行ClassIn自动登录.bat」即可
# 依赖：Windows + PowerShell（系统自带，无需安装其他软件）
# 说明：启动 ClassIn 并自动填入账号密码、按回车登录
# ============================================================

$ErrorActionPreference = "Stop"

# ---- 路径 ----
$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$configFile  = Join-Path $scriptDir "classin_config.txt"
$credFile    = Join-Path $scriptDir "classin_credentials.txt"

# ---- 读取 key=value 配置 ----
function Read-Ini($path) {
    $map = @{}
    if (-not (Test-Path $path)) { return $map }
    foreach ($line in (Get-Content $path -Encoding UTF8)) {
        $line = $line.Trim()
        if ($line -eq "" -or $line.StartsWith("#")) { continue }
        if ($line -match "^([^=]+)=(.*)$") {
            $map[$Matches[1].Trim()] = $Matches[2].Trim()
        }
    }
    return $map
}

$cfg  = Read-Ini $configFile
$cred = Read-Ini $credFile

$classinPath = if ($cfg["classin_path"]) { $cfg["classin_path"] } else { "C:\Program Files (x86)\ClassIn\ClassIn.exe" }
$procName    = if ($cfg["proc_name"])    { $cfg["proc_name"] }    else { "ClassIn" }
$waitTimeout = if ($cfg["wait_timeout"]) { [int]$cfg["wait_timeout"] } else { 30 }
$accountX    = if ($cfg["account_x"])    { [int]$cfg["account_x"] } else { $null }
$accountY    = if ($cfg["account_y"])    { [int]$cfg["account_y"] } else { $null }
$passwordX   = if ($cfg["password_x"])   { [int]$cfg["password_x"] } else { $null }
$passwordY   = if ($cfg["password_y"])   { [int]$cfg["password_y"] } else { $null }

$account  = $cred["account"]
$password = $cred["password"]

if (-not $account -or $account -like "在这里填*") {
    Write-Host "ERROR: 请先在 classin_credentials.txt 中填写 account" -ForegroundColor Red
    exit 1
}
if (-not $password -or $password -like "在这里填*") {
    Write-Host "ERROR: 请先在 classin_credentials.txt 中填写 password" -ForegroundColor Red
    exit 1
}

# ---- Win32 API ----
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinApi {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, int dwExtraInfo);
}
"@

function Send-KeysEscaped($text) {
    # SendKeys 对 + ^ % ~ ( ) [ ] { } 等特殊字符需用花括号包裹
    $text = $text -replace '([{+^%~()\[\]])', '{$1}'
    [System.Windows.Forms.SendKeys]::SendWait($text)
}

function Click-Point($x, $y) {
    [WinApi]::SetCursorPos($x, $y)
    [WinApi]::mouse_event(0x0002, 0, 0, 0, 0)  # 左键按下
    [WinApi]::mouse_event(0x0004, 0, 0, 0, 0)  # 左键抬起
    Start-Sleep -Milliseconds 150
}

# ---- 启动 ClassIn ----
$proc = Get-Process -Name $procName -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $proc) {
    if (-not (Test-Path $classinPath)) {
        Write-Host "ERROR: 找不到 ClassIn：$classinPath" -ForegroundColor Red
        Write-Host "请修改 classin_config.txt 中的 classin_path 为你的真实路径" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "启动 ClassIn ..."
    Start-Process $classinPath
} else {
    Write-Host "ClassIn 已在运行"
}

# ---- 等待登录窗口 ----
Write-Host "等待登录窗口出现（最多 $waitTimeout 秒）..."
$deadline = (Get-Date).AddSeconds($waitTimeout)
$hwnd = [IntPtr]::Zero
while ((Get-Date) -lt $deadline) {
    $p = Get-Process -Name $procName -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($p -and $p.MainWindowHandle -ne [IntPtr]::Zero) {
        $hwnd = $p.MainWindowHandle
        break
    }
    Start-Sleep -Milliseconds 500
}
if ($hwnd -eq [IntPtr]::Zero) {
    Write-Host "ERROR: 超时未找到 ClassIn 窗口，请确认客户端已正常启动" -ForegroundColor Red
    exit 1
}

# 激活并前置窗口
[WinApi]::ShowWindow($hwnd, 9)   # SW_RESTORE
[WinApi]::SetForegroundWindow($hwnd)
Start-Sleep -Milliseconds 800

# ---- 输入凭据 ----
$useCoord = ($accountX -ne $null -and $accountY -ne $null -and $passwordX -ne $null -and $passwordY -ne $null)
if ($useCoord) {
    Write-Host "坐标模式：点击账号框 / 密码框并输入"
    Click-Point $accountX $accountY
    [System.Windows.Forms.SendKeys]::SendWait("^a")
    [System.Windows.Forms.SendKeys]::SendWait("{DEL}")
    Send-KeysEscaped $account
    Start-Sleep -Milliseconds 200
    Click-Point $passwordX $passwordY
    [System.Windows.Forms.SendKeys]::SendWait("^a")
    [System.Windows.Forms.SendKeys]::SendWait("{DEL}")
    Send-KeysEscaped $password
    Start-Sleep -Milliseconds 200
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
} else {
    Write-Host "键盘模式：直接输入（假设账号框已自动聚焦）"
    Send-KeysEscaped $account
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    Start-Sleep -Milliseconds 200
    Send-KeysEscaped $password
    Start-Sleep -Milliseconds 200
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}

Write-Host "已提交登录。若未能成功登录，请运行『获取坐标.bat』切换为更稳的坐标模式。" -ForegroundColor Green
Start-Sleep -Seconds 2

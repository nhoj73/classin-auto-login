# ============================================================
# 坐标采集工具：把鼠标移到账号框 / 密码框，记录屏幕坐标写入配置
# 用法：双击「获取坐标.bat」
# ============================================================

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$cfgFile   = Join-Path $scriptDir "classin_config.txt"

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Cur {
    [DllImport("user32.dll")] public static extern bool GetCursorPos(out POINT p);
    public struct POINT { public int X; public int Y; }
}
"@

function GetPos {
    $p = New-Object Cur+POINT
    [Cur]::GetCursorPos([ref]$p) | Out-Null
    return $p
}

Write-Host "=== ClassIn 坐标采集工具 ===" -ForegroundColor Cyan
Write-Host "提示：先把 ClassIn 登录窗口打开并放到不遮挡的位置。" -ForegroundColor Yellow

Write-Host "`n[1] 把鼠标移到【账号输入框】上，然后按 Enter"
Read-Host "移到账号框后按 Enter" | Out-Null
$a = GetPos
Write-Host ("账号框坐标: X={0}  Y={1}" -f $a.X, $a.Y)

Write-Host "`n[2] 再把鼠标移到【密码输入框】上，然后按 Enter"
Read-Host "移到密码框后按 Enter" | Out-Null
$pw = GetPos
Write-Host ("密码框坐标: X={0}  Y={1}" -f $pw.X, $pw.Y)

# 写回 config
$new = @()
if (Test-Path $cfgFile) { $new = Get-Content $cfgFile -Encoding UTF8 }
$out = @()
foreach ($l in $new) {
    if     ($l -match "^account_x=")  { $out += ("account_x="  + $a.X) }
    elseif ($l -match "^account_y=")  { $out += ("account_y="  + $a.Y) }
    elseif ($l -match "^password_x=") { $out += ("password_x=" + $pw.X) }
    elseif ($l -match "^password_y=") { $out += ("password_y=" + $pw.Y) }
    else { $out += $l }
}
$out | Set-Content $cfgFile -Encoding UTF8
Write-Host "`n已写入 classin_config.txt，现在双击『运行ClassIn自动登录.bat』即可使用坐标模式。" -ForegroundColor Green
Read-Host "按 Enter 退出" | Out-Null

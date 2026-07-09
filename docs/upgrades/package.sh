#!/bin/bash
# ============================================================
# 把这次改动打包成一个 tar.gz，便于离线分发到其他机器
# 输出：docs/upgrades/dist/ip-location-from-client-2026-06-29.tar.gz
# ============================================================
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
OUT_DIR="$PROJECT_DIR/docs/upgrades/dist"
PKG_NAME="ip-location-from-client-2026-06-29"
STAGE=$(mktemp -d)
trap "rm -rf $STAGE" EXIT

mkdir -p "$OUT_DIR" "$STAGE/$PKG_NAME"

cd "$PROJECT_DIR"

# === 改动文件 ===
cp dash-fastapi-backend/module_admin/annotation/log_annotation.py \
   "$STAGE/$PKG_NAME/log_annotation.py"
cp dash-fastapi-frontend/utils/request.py \
   "$STAGE/$PKG_NAME/request.py"
cp dash-fastapi-frontend/assets/js/login_location.js \
   "$STAGE/$PKG_NAME/login_location.js"

# === 文档 ===
cp docs/upgrades/ip-location-from-client-2026-06-29.md \
   "$STAGE/$PKG_NAME/README.md"
cp docs/upgrades/ip-location-from-client-windows-deploy-2026-06-29.md \
   "$STAGE/$PKG_NAME/README-Windows.md"

# === Linux 脚本 ===
cp docs/upgrades/ip-location-from-client-2026-06-29-deploy.sh \
   "$STAGE/$PKG_NAME/deploy.sh"
cp docs/upgrades/ip-location-from-client-2026-06-29-rollback.sh \
   "$STAGE/$PKG_NAME/rollback.sh"

# === Patch 备用（给有 git 的机器用） ===
cp docs/upgrades/ip-location-from-client-2026-06-29.patch \
   "$STAGE/$PKG_NAME/"

# === Windows PowerShell 脚本（写一个） ===
cat > "$STAGE/$PKG_NAME/deploy-windows.ps1" <<'PSEOF'
# ============================================================
# Windows 一键升级脚本（PowerShell）
# 用法：
#   1. 把整个 ip-location-from-client-2026-06-29 文件夹拷到 Windows
#   2. 管理员 PowerShell 跑：
#        .\deploy-windows.ps1 -Dst "C:\path\to\dash-fastapi-admin"
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$Dst,
    [string]$BundleDir = (Split-Path -Parent $MyInvocation.MyCommand.Path)
)

$ErrorActionPreference = "Stop"
$pyExe = (Get-Command python).Source
if (-not $pyExe) { Write-Host "✗ 找不到 python" -ForegroundColor Red; exit 1 }
Write-Host "✓ Python: $pyExe"

# 1. 停服
Write-Host "`n[1/6] 停服..." -ForegroundColor Cyan
foreach ($svc in @("DashBackend", "DashFrontend")) {
    try { & nssm stop $svc 2>$null; Write-Host "  ✓ stop $svc" } catch {}
}
Start-Sleep -Seconds 2

# 2. 备份
Write-Host "`n[2/6] 备份..." -ForegroundColor Cyan
$backup = "C:\backup\dash-ip-location-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $backup -Force | Out-Null
foreach ($f in @(
    "dash-fastapi-backend\module_admin\annotation\log_annotation.py",
    "dash-fastapi-frontend\utils\request.py"
)) {
    $src = "$Dst\$f"
    if (Test-Path $src) {
        $dstDir = Split-Path "$backup\$f" -Parent
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        Copy-Item $src "$backup\$f" -Force
        Write-Host "  ✓ $f"
    }
}
Write-Host "  备份到: $backup"

# 3. 复制文件
Write-Host "`n[3/6] 复制 3 个文件..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path "$Dst\dash-fastapi-backend\module_admin\annotation" -Force | Out-Null
New-Item -ItemType Directory -Path "$Dst\dash-fastapi-frontend\utils" -Force | Out-Null
New-Item -ItemType Directory -Path "$Dst\dash-fastapi-frontend\assets\js" -Force | Out-Null

Copy-Item "$BundleDir\log_annotation.py" "$Dst\dash-fastapi-backend\module_admin\annotation\log_annotation.py" -Force
Copy-Item "$BundleDir\request.py" "$Dst\dash-fastapi-frontend\utils\request.py" -Force
Copy-Item "$BundleDir\login_location.js" "$Dst\dash-fastapi-frontend\assets\js\login_location.js" -Force
Write-Host "  ✓ 3 个文件就位"

# 4. 清 pycache
Write-Host "`n[4/6] 清 pycache..." -ForegroundColor Cyan
Get-ChildItem "$Dst\dash-fastapi-backend", "$Dst\dash-fastapi-frontend" `
    -Recurse -Filter "__pycache__" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
Get-ChildItem "$Dst\dash-fastapi-backend", "$Dst\dash-fastapi-frontend" `
    -Recurse -Filter "*.pyc" -ErrorAction SilentlyContinue | Remove-Item -Force

# 5. 语法校验
Write-Host "`n[5/6] 语法校验..." -ForegroundColor Cyan
& $pyExe -m py_compile `
    "$Dst\dash-fastapi-backend\module_admin\annotation\log_annotation.py" `
    "$Dst\dash-fastapi-frontend\utils\request.py"
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ Python 语法错误！从备份回滚" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Python OK"
if (Get-Command node -ErrorAction SilentlyContinue) {
    & node --check "$Dst\dash-fastapi-frontend\assets\js\login_location.js"
    if ($LASTEXITCODE -eq 0) { Write-Host "  ✓ JS OK" }
}

# 6. 重启
Write-Host "`n[6/6] 重启服务..." -ForegroundColor Cyan
foreach ($svc in @("DashBackend", "DashFrontend")) {
    try { & nssm start $svc 2>$null; Write-Host "  ✓ start $svc" } catch {}
}
Start-Sleep -Seconds 3

foreach ($port in @(38039, 9099)) {
    if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) {
        Write-Host "  ✓ 端口 $port 监听中"
    } else {
        Write-Host "  ✗ 端口 $port 未监听" -ForegroundColor Red
    }
}

Write-Host "`n✅ 升级完成，浏览器 DevTools 应能看到 X-Login-Location header" -ForegroundColor Green
PSEOF

# === 回滚脚本 (Windows 版) ===
cat > "$STAGE/$PKG_NAME/rollback-windows.ps1" <<'PSEOF'
# ============================================================
# Windows 回滚脚本
# 用法：.\rollback-windows.ps1 -Dst "C:\path\to\dash-fastapi-admin" -Backup "C:\backup\dash-ip-location-xxx"
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$Dst,
    [Parameter(Mandatory=$true)][string]$Backup
)

$ErrorActionPreference = "Stop"
Write-Host "停服..." -ForegroundColor Cyan
foreach ($svc in @("DashBackend", "DashFrontend")) {
    try { & nssm stop $svc 2>$null } catch {}
}
Start-Sleep -Seconds 2

Write-Host "从 $Backup 恢复..." -ForegroundColor Cyan
foreach ($f in @(
    "dash-fastapi-backend\module_admin\annotation\log_annotation.py",
    "dash-fastapi-frontend\utils\request.py"
)) {
    $src = "$Backup\$f"
    $dst = "$Dst\$f"
    if (Test-Path $src) {
        Copy-Item $src $dst -Force
        Write-Host "  ✓ 恢复 $f"
    }
}
Remove-Item "$Dst\dash-fastapi-frontend\assets\js\login_location.js" -Force -ErrorAction SilentlyContinue
Write-Host "  ✓ 删除 login_location.js"

Write-Host "清 pycache..." -ForegroundColor Cyan
Get-ChildItem "$Dst\dash-fastapi-backend", "$Dst\dash-fastapi-frontend" `
    -Recurse -Filter "__pycache__" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force

Write-Host "重启..." -ForegroundColor Cyan
foreach ($svc in @("DashBackend", "DashFrontend")) {
    try { & nssm start $svc 2>$null; Write-Host "  ✓ start $svc" } catch {}
}
Write-Host "`n✅ 回滚完成" -ForegroundColor Green
PSEOF

# === 备份（如果存在则带上） ===
if [ -d backups ]; then
    mkdir -p "$STAGE/$PKG_NAME/backups"
    find backups -maxdepth 1 -type f -name "*.bak.*" \
        -exec cp {} "$STAGE/$PKG_NAME/backups/" \; 2>/dev/null || true
fi

chmod +x "$STAGE/$PKG_NAME/deploy.sh" "$STAGE/$PKG_NAME/rollback.sh"

# 生成 MD5 校验（排除 backups 目录）
( cd "$STAGE/$PKG_NAME" && find . -maxdepth 1 -type f -exec md5sum {} \; | sort -k 2 > md5sum.txt )

# 打包
tar czf "$OUT_DIR/$PKG_NAME.tar.gz" -C "$STAGE" "$PKG_NAME"

echo
echo "=== 打包完成 ==="
ls -la "$OUT_DIR/$PKG_NAME.tar.gz"
echo
echo "MD5:"
md5sum "$OUT_DIR/$PKG_NAME.tar.gz"
echo
echo "包内文件:"
tar tzf "$OUT_DIR/$PKG_NAME.tar.gz"

# ============================================================
# === Direct 模式（上午那种风格）===
# 直接覆盖用的 tar.gz，路径前缀是 dash-fastapi-admin/
# 在 Windows 上 tar -xzf -C D:\workspace\dash-fastapi-admin 即可
# ============================================================
DIRECT_BUNDLE="$OUT_DIR/ip-location-bundle.tar.gz"
tar czf "$DIRECT_BUNDLE" \
  --transform 's|^|dash-fastapi-admin/|' \
  dash-fastapi-backend/module_admin/annotation/log_annotation.py \
  dash-fastapi-frontend/utils/request.py \
  dash-fastapi-frontend/assets/js/login_location.js

echo
echo "=== Direct 模式打包完成 ==="
echo "  文件: $DIRECT_BUNDLE"
ls -lh "$DIRECT_BUNDLE"
echo
echo "  Windows 上用法："
echo "    tar -xzf ip-location-bundle.tar.gz -C D:\\workspace\\dash-fastapi-admin"
echo "    nssm restart DashBackend"
echo "    nssm restart DashFrontend"

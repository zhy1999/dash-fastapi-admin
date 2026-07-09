#!/bin/bash
# ============================================================
# IP 归属地改用客户端 Header — 一键部署脚本
# 适用：dash-fastapi-admin 项目升级
# 日期：2026-06-29
# ============================================================
set -e

# ---------- 配置 ----------
PROJECT_DIR="${PROJECT_DIR:-/opt/dash-fastapi-admin}"
PATCH_FILE="${PATCH_FILE:-docs/upgrades/ip-location-from-client-2026-06-29.patch}"
BACKEND_SERVICE="${BACKEND_SERVICE:-dash-fastapi-backend}"
FRONTEND_SERVICE="${FRONTEND_SERVICE:-dash-fastapi-frontend}"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d_%H%M%S)"

# ---------- 颜色 ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ---------- 前置检查 ----------
[ -d "$PROJECT_DIR" ] || error "项目目录不存在: $PROJECT_DIR"
cd "$PROJECT_DIR"

[ -f "$PATCH_FILE" ] || error "Patch 文件不存在: $PATCH_FILE"
command -v git >/dev/null || error "需要 git 命令"

# ---------- 1. 备份 ----------
info "1/5 备份现有文件..."
mkdir -p backups
for f in \
    dash-fastapi-backend/module_admin/annotation/log_annotation.py \
    dash-fastapi-frontend/utils/request.py \
    dash-fastapi-frontend/assets/js/login_location.js
do
    if [ -f "$f" ]; then
        cp "$f" "backups/$(basename $f)${BACKUP_SUFFIX}"
        info "  已备份: $f → backups/$(basename $f)${BACKUP_SUFFIX}"
    fi
done

# ---------- 2. 检查 patch 是否已应用 ----------
info "2/5 检查 patch 状态..."
if git apply --check "$PATCH_FILE" 2>/dev/null; then
    NEED_APPLY=1
elif git apply --check --reverse "$PATCH_FILE" 2>/dev/null; then
    NEED_APPLY=0
    warn "  Patch 已经应用过，跳过 apply 步骤"
else
    error "Patch 既不能正向也不能反向 apply，请手工处理冲突"
fi

# ---------- 3. 应用 patch ----------
if [ "$NEED_APPLY" = "1" ]; then
    info "3/5 应用 patch..."
    git apply "$PATCH_FILE" || error "Patch apply 失败"
    info "  Patch 应用成功"
else
    info "3/5 跳过 apply（已应用过）"
fi

# ---------- 4. 验证 ----------
info "4/5 验证文件..."
for f in \
    dash-fastapi-backend/module_admin/annotation/log_annotation.py \
    dash-fastapi-frontend/utils/request.py \
    dash-fastapi-frontend/assets/js/login_location.js
do
    [ -f "$f" ] || error "文件缺失: $f"
done

# Python 语法检查
if command -v python3 >/dev/null; then
    python3 -c "import ast; ast.parse(open('dash-fastapi-backend/module_admin/annotation/log_annotation.py').read())" \
        || error "log_annotation.py 语法错误"
    python3 -c "import ast; ast.parse(open('dash-fastapi-frontend/utils/request.py').read())" \
        || error "request.py 语法错误"
    info "  Python 语法检查通过"
fi

# JS 语法检查
if command -v node >/dev/null; then
    node --check dash-fastapi-frontend/assets/js/login_location.js \
        || error "login_location.js 语法错误"
    info "  JS 语法检查通过"
fi

# ---------- 5. 重启服务 ----------
info "5/5 重启服务..."
if command -v systemctl >/dev/null; then
    sudo systemctl restart "$BACKEND_SERVICE" || warn "重启 $BACKEND_SERVICE 失败，请手工检查"
    sudo systemctl restart "$FRONTEND_SERVICE" || warn "重启 $FRONTEND_SERVICE 失败，请手工检查"
    sleep 2
    sudo systemctl status "$BACKEND_SERVICE" --no-pager -l | head -3
    sudo systemctl status "$FRONTEND_SERVICE" --no-pager -l | head -3
elif command -v supervisorctl >/dev/null; then
    sudo supervisorctl restart "$BACKEND_SERVICE" "$FRONTEND_SERVICE"
else
    warn "未检测到 systemctl 或 supervisorctl，请手工重启服务"
fi

info "========================================="
info "部署完成！建议执行以下验证："
echo "  1. 浏览器打开应用，DevTools → Network → 任意 callback 请求"
echo "     应能看到 header: X-Login-Location: <具体地址>"
echo "  2. 登录一次后查数据库 logininfor 表"
echo "     SELECT user_name, ipaddr, login_location FROM logininfor ORDER BY login_time DESC LIMIT 1;"
info "========================================="

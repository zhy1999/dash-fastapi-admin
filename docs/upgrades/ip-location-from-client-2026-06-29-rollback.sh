#!/bin/bash
# ============================================================
# IP 归属地改用客户端 Header — 回滚脚本
# 用法：bash docs/upgrades/ip-location-from-client-2026-06-29-rollback.sh
# ============================================================
set -e

PROJECT_DIR="${PROJECT_DIR:-/opt/dash-fastapi-admin}"
PATCH_FILE="${PATCH_FILE:-docs/upgrades/ip-location-from-client-2026-06-29.patch}"
BACKEND_SERVICE="${BACKEND_SERVICE:-dash-fastapi-backend}"
FRONTEND_SERVICE="${FRONTEND_SERVICE:-dash-fastapi-frontend}"

cd "$PROJECT_DIR" || { echo "[ERROR] 项目目录不存在: $PROJECT_DIR"; exit 1; }

echo "[INFO] 1/3 反向 apply patch..."
if git apply --check --reverse "$PATCH_FILE" 2>/dev/null; then
    git apply --reverse "$PATCH_FILE"
    echo "[INFO]  patch 已反向 apply"
else
    echo "[WARN]  无法反向 apply（可能未应用或已手工处理）"
fi

echo "[INFO] 2/3 检查 backups 目录..."
if [ -d backups ]; then
    echo "[INFO]  找到以下备份："
    ls -la backups/
    echo
    read -p "[?]  是否用 backups/ 目录的最新备份覆盖？(y/N) " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        latest() { ls -t "backups/$1".bak.* 2>/dev/null | head -1; }
        for f in \
            "dash-fastapi-backend/module_admin/annotation/log_annotation.py:log_annotation.py" \
            "dash-fastapi-frontend/utils/request.py:request.py"
        do
            src="${f%%:*}"
            name="${f##*:}"
            bak=$(latest "$name")
            if [ -n "$bak" ]; then
                cp "$bak" "$src"
                echo "[INFO]  $src ← $bak"
            fi
        done
    fi
fi

echo "[INFO] 3/3 重启服务..."
if command -v systemctl >/dev/null; then
    sudo systemctl restart "$BACKEND_SERVICE" "$FRONTEND_SERVICE" 2>/dev/null || true
elif command -v supervisorctl >/dev/null; then
    sudo supervisorctl restart "$BACKEND_SERVICE" "$FRONTEND_SERVICE" 2>/dev/null || true
fi

echo "[INFO] 回滚完成"

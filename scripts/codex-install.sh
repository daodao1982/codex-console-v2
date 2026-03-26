#!/bin/bash

echo "=== 开始安装 codex-console 注册机 ==="

# 使用 GitHub 仓库安装 (126 备份版本)
if [ -d "/root/codex-console" ]; then
    echo "代码已存在，更新中..."
    cd /root/codex-console
    git pull origin main
else
    echo "克隆仓库中..."
    git clone https://github.com/daodao1982/codex-console-v2.git /root/codex-console
    cd /root/codex-console
fi

echo "修改注册限制为5000..."
sed -i 's/request.count < 1 or request.count > 100/request.count < 1 or request.count > 5000/g' src/web/routes/registration.py
sed -i 's/注册数量 (1-100)/注册数量 (1-5000)/g; s/max="100"/max="5000"/g' templates/index.html

mkdir -p data logs

echo "构建镜像中..."
docker build -t codex-register .

echo "启动容器..."
docker rm -f codex-register 2>/dev/null || true
docker run -d --name codex-register \
    -p 8050:1455 \
    -v /root/codex-console/data:/app/data \
    -v /root/codex-console/logs:/app/logs \
    -e HTTP_PROXY="" \
    -e HTTPS_PROXY="" \
    codex-register

sleep 5

echo "安装 starlette 修复..."
docker exec codex-register pip install --no-cache-dir 'starlette==0.52.1' 2>/dev/null
docker restart codex-register

echo "=== 安装完成 ==="
echo "访问地址: http://你的IP:8050"
#!/bin/bash

# Auto-install Docker if not present
install_docker() {
    echo "=== Docker 未安装，正在安装 ==="
    curl -fsSL https://get.docker.com | bash
    systemctl start docker
    systemctl enable docker
    echo "=== Docker 安装完成 ==="
}

# Check if docker exists
if ! command -v docker &> /dev/null; then
    install_docker
fi

# Continue with main installation
echo "=== 开始安装 codex-console 注册机 ==="
git clone https://github.com/daodao1982/codex-console-v2.git /root/codex-console
cd /root/codex-console

echo "修改注册限制为5000..."
sed -i 's/request.count < 1 or request.count > 100/request.count < 1 or request.count > 5000/g' src/web/routes/registration.py
sed -i 's/max="100"/max="5000"/g' templates/index.html

mkdir -p data logs
echo "构建镜像中..."
docker build -t codex-register .

echo "启动容器..."
docker rm -f codex-register 2>/dev/null || true
docker run -d --name codex-register -p 8050:1455 -v /root/codex-console/data:/app/data -v /root/codex-console/logs:/app/logs codex-register

sleep 5
echo "安装 starlette 修复..."
docker exec codex-register pip install --no-cache-dir 'starlette==0.52.1' 2>/dev/null
docker restart codex-register

echo "=== 安装完成 ==="
echo "访问地址: http://你的IP:8050"

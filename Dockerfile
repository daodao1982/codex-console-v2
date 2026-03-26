FROM codex-local:latest

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV WEBUI_HOST=0.0.0.0
ENV WEBUI_PORT=1455
ENV DISPLAY=:99
ENV ENABLE_VNC=1

# 安装系统依赖
# (curl_cffi 等库可能需要编译工具)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        python3-dev \
        xvfb \
        fluxbox \
        x11vnc \
        websockify \
        novnc \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件并安装
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir starlette==0.52.1 \
    && python -m playwright install --with-deps chromium

# 复制项目代码
COPY . .

# 暴露端口
EXPOSE 1455 6080 5900

# 启动脚本
CMD ["bash", "scripts/docker/start-webui.sh"]

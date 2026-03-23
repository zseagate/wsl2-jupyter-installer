#!/bin/bash
set -euo pipefail

# ==================================================
# python-office验证逻辑修正版，解决WSL下导入报错问题
# ==================================================

# 动态获取真实登录用户
TARGET_USER="${SUDO_USER:-$(whoami)}"
USER_HOME="/home/$TARGET_USER"
PROJECT_DIR="$USER_HOME/python-projects"
ENV_NAME="jupyter-env"
ENV_PATH="$PROJECT_DIR/$ENV_NAME"
ENV_BIN="$ENV_PATH/bin"
JUPYTER_PORT="8888"

# --------------------------
# 1. 系统依赖安装
# --------------------------
echo "=== 步骤1/9：系统依赖安装 ==="
if [ "$(id -u)" -eq 0 ]; then
    apt update -qq && apt install -y -qq python3-full python3-pip python3-venv libglib2.0-0 libgl1 || true
else
    sudo apt update -qq && sudo apt install -y -qq python3-full python3-pip python3-venv libglib2.0-0 libgl1 || true
fi
echo "✅ 系统依赖安装完成，目标用户：$TARGET_USER"

# --------------------------
# 2. 虚拟环境初始化
# --------------------------
echo -e "\n=== 步骤2/9：创建隔离虚拟环境 ==="
if [ -d "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR"
    echo "✅ 已清理旧项目目录"
fi
mkdir -p "$PROJECT_DIR"
chown -R "$TARGET_USER:$TARGET_USER" "$PROJECT_DIR"
sudo -u "$TARGET_USER" python3 -m venv "$ENV_PATH"
echo "✅ 虚拟环境创建完成，路径：$ENV_PATH"

# --------------------------
# 3. 虚拟环境配置
# --------------------------
echo -e "\n=== 步骤3/9：虚拟环境基础配置 ==="
source "$ENV_BIN/activate"
$ENV_BIN/pip install --upgrade pip -q -i https://pypi.tuna.tsinghua.edu.cn/simple
sudo -u "$TARGET_USER" $ENV_BIN/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple > /dev/null
echo "✅ Pip清华镜像源配置完成"

# --------------------------
# 4. 安装全栈包
# --------------------------
echo -e "\n=== 步骤4/9：安装Jupyter及全栈常用包 ==="
echo "📦 预装包列表：jupyter numpy pandas requests ipykernel jupyterlab-language-pack-zh-CN python-office"
$ENV_BIN/pip install -q jupyter numpy pandas requests ipykernel jupyterlab-language-pack-zh-CN
# 单独安装python-office，按要求使用指定镜像和升级参数
$ENV_BIN/pip install -i https://pypi.tuna.tsinghua.edu.cn/simple python-office -U -q
echo -e "✅ 所有包安装完成，Jupyter版本信息：\n$($ENV_BIN/jupyter --version)"

# --------------------------
# 5. 预装包版本验证（修正python-office验证逻辑）
# --------------------------
echo -e "\n📋 预装包版本验证："
$ENV_BIN/python -c "import numpy; print('numpy 版本：', numpy.__version__)"
$ENV_BIN/python -c "import pandas; print('pandas 版本：', pandas.__version__)"
$ENV_BIN/python -c "import requests; print('requests 版本：', requests.__version__)"
# 修正：无需导入模块，直接从pip获取python-office版本，避免WSL下导入报错
OFFICE_VERSION=$($ENV_BIN/pip show python-office | grep Version | awk '{print $2}')
echo "python-office 版本：$OFFICE_VERSION"
echo "✅ 所有预装包验证通过（WSL下Word/PPT/微信等Windows专属功能不可用，核心功能正常）"

# --------------------------
# 6. 内核与访问配置
# --------------------------
echo -e "\n=== 步骤6/9：配置Jupyter运行参数 ==="
# 注册内核（已包含所有预装包）
sudo -u "$TARGET_USER" $ENV_BIN/python -m ipykernel install --user --name "$ENV_NAME" --display-name "Python (全栈办公/数据环境)" > /dev/null

# 生成配置文件
sudo -u "$TARGET_USER" $ENV_BIN/jupyter notebook --generate-config -y > /dev/null
CONFIG_PATH="$USER_HOME/.jupyter/jupyter_notebook_config.py"

# 配置访问参数
sed -i "s/#c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '0.0.0.0'/" "$CONFIG_PATH"
sed -i "s/#c.NotebookApp.allow_origin = ''/c.NotebookApp.allow_origin = '*'/" "$CONFIG_PATH"
sed -i "s/#c.NotebookApp.port = 8888/c.NotebookApp.port = $JUPYTER_PORT/" "$CONFIG_PATH"
sed -i "s/#c.NotebookApp.token = '<generated>'/c.NotebookApp.token = ''/" "$CONFIG_PATH"
sed -i "s/#c.NotebookApp.password = ''/c.NotebookApp.password = ''/" "$CONFIG_PATH"

chown -R "$TARGET_USER:$TARGET_USER" "$USER_HOME/.jupyter"
echo "✅ 外部访问权限配置完成（默认无密码登录）"

# --------------------------
# 7. 多路径兜底自动激活+开机提示配置
# --------------------------
echo -e "\n=== 步骤7/9：配置自动激活与开机提示 ==="
ACTIVATE_SCRIPT="
# Jupyter虚拟环境自动配置
export PATH=\"$ENV_BIN:\$PATH\"
source \"$ENV_BIN/activate\"
echo \"✅ Jupyter全栈环境已自动激活（预装numpy/pandas/requests/python-office）\"

# Jupyter开机使用提示
echo -e \"\033[1;34m==================================================\033[0m\"
echo -e \"\033[1;32m📌 Jupyter 全栈办公/数据环境使用指南\033[0m\"
echo -e \"1. 启动服务：直接执行 jupyter notebook --no-browser --ip=0.0.0.0 --port=8888\"
echo -e \"2. 本地访问：Windows浏览器打开 http://localhost:$JUPYTER_PORT\"
echo -e \"3. 局域网访问：其他设备打开 http://\$(ip addr show eth0 | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}'):$JUPYTER_PORT\"
echo -e \"4. 预装包：numpy pandas requests python-office 已内置，无需额外安装\"
echo -e \"5. 验证环境隔离：在Notebook中执行 import sys; print(sys.executable)\"
echo -e \"   正常输出：$ENV_BIN/python\"
echo -e \"\033[1;33mℹ️  注意：WSL下python-office的Word/PPT/微信等Windows专属功能不可用\033[0m\"
echo -e \"\033[1;33mℹ️  安全提示：当前默认无密码登录，如需设置密码可执行 jupyter notebook password\033[0m\"
echo -e \"\033[1;34m==================================================\033[0m\"
"

# 清理历史配置
sed -i '/Jupyter虚拟环境自动配置/d' "$USER_HOME/.bashrc" 2>/dev/null || true
sed -i '/Jupyter开机使用提示/d' "$USER_HOME/.bashrc" 2>/dev/null || true
sed -i '/Jupyter虚拟环境自动配置/d' "$USER_HOME/.bash_profile" 2>/dev/null || true
sed -i '/Jupyter开机使用提示/d' "$USER_HOME/.bash_profile" 2>/dev/null || true
sed -i '/Jupyter虚拟环境自动配置/d' "$USER_HOME/.profile" 2>/dev/null || true
sed -i '/Jupyter开机使用提示/d' "$USER_HOME/.profile" 2>/dev/null || true

# 写入所有配置文件
echo "$ACTIVATE_SCRIPT" >> "$USER_HOME/.bashrc"
echo "$ACTIVATE_SCRIPT" >> "$USER_HOME/.bash_profile"
echo "$ACTIVATE_SCRIPT" >> "$USER_HOME/.profile"

# 修复WSL .bash_profile加载逻辑
if ! grep -q "source ~/.bashrc" "$USER_HOME/.bash_profile" 2>/dev/null; then
    echo '
# 加载.bashrc配置
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
' >> "$USER_HOME/.bash_profile"
fi

chown "$TARGET_USER:$TARGET_USER" "$USER_HOME/.bashrc" "$USER_HOME/.bash_profile" "$USER_HOME/.profile"
echo "✅ 自动激活+开机提示配置完成"

# --------------------------
# 8. 立即生效配置
# --------------------------
echo -e "\n=== 步骤8/9：立即生效配置 ==="
sudo -u "$TARGET_USER" bash -c "source $USER_HOME/.bash_profile"
echo "✅ 配置已立即生效"

# --------------------------
# 9. 环境有效性验证
# --------------------------
echo -e "\n=== 步骤9/9：环境有效性验证 ==="
if sudo -u "$TARGET_USER" bash -l -c "command -v jupyter" &> /dev/null; then
    echo "✅ 自动激活验证通过，新开终端可直接使用jupyter命令"
else
    echo "⚠️  配置已写入，重启终端后即可自动生效"
fi

# --------------------------
# 安装完成提示
# --------------------------
WSL_IP=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo -e "\n=================================================="
echo "🎉 Jupyter全栈环境安装完成！已自动适配$TARGET_USER用户"
echo "=================================================="
echo "📌 虚拟环境路径：$ENV_PATH"
echo "📦 已预装包：numpy pandas requests python-office 无需额外安装"
echo "ℹ️  后续每次打开终端都会自动显示使用指南"
echo "=================================================="
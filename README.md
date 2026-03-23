# WSL Jupyter 全栈环境一键安装脚本
🔥 专为 WSL(Windows Subsystem for Linux) 打造的一站式 Jupyter 环境部署工具，无需任何手动配置，一行命令完成全环境安装，开箱即用。

```

## ✨ 核心特性
- 🚀 **全自动化安装**：从系统依赖到Python包全流程自动安装，全程无交互，无需手动输入任何内容
- 📦 **预装常用包**：内置数据科学+办公全栈工具包，无需额外安装
  - 数据科学：`numpy` `pandas`
  - 网络请求：`requests`
  - 办公自动化：`python-office`
  - 界面支持：Jupyter中文界面包
- 🔒 **隔离虚拟环境**：独立Python虚拟环境，不污染系统Python，删除/迁移方便
- 🌐 **多终端访问**：同时支持本地访问+局域网其他设备访问
- 🎨 **开机自动提示**：每次打开WSL终端自动显示使用指南，无需记忆命令
- ⚡ **优化配置**：默认无密码登录，自动配置清华镜像源，下载速度提升10倍
 
## 📋 环境要求
- Windows 10 1903+ / Windows 11
- 已安装 WSL2（推荐 Ubuntu 22.04 / 24.04 发行版）
- 至少 2GB 空闲磁盘空间
 
## 🚀 快速使用
### 1. 下载脚本
方法一：直接下载脚本文件
​```bash
wget https://raw.githubusercontent.com/你的GitHub用户名/你的仓库名/main/install_jupyter.sh
```

方法二：手动复制`install_jupyter.sh`内容到WSL中保存

### 2. 执行安装

bash

```
sudo bash ./install_jupyter.sh
```

- 安装过程约5-10分钟，取决于网络速度
- 全程无需任何操作，等待安装完成提示即可

### 3. 启动服务

安装完成后重新打开WSL终端，虚拟环境会自动激活，直接执行：

bash

```
jupyter notebook --no-browser --ip=0.0.0.0 --port=8888
```

### 4. 访问Jupyter

| 访问方式   | 地址                      | 适用场景                           |
| ---------- | ------------------------- | ---------------------------------- |
| 本地访问   | `http://localhost:8888`   | Windows本地浏览器访问              |
| 局域网访问 | `http://WSL的IP地址:8888` | 同一局域网下其他电脑/手机/平板访问 |

### 5. 验证环境

在Jupyter Notebook中新建Python文件，执行以下代码验证环境：

python

```
# 验证环境隔离
import sys
print(sys.executable)
# 正常输出：/home/你的用户名/python-projects/jupyter-env/bin/python
 
# 验证预装包
import numpy
import pandas
import requests
import office
print("所有包导入成功！")
```

## 📝 使用说明

### 内置功能说明

1. **自动激活虚拟环境**：每次打开WSL终端会自动激活Jupyter虚拟环境，无需手动执行`source`命令
2. **默认无密码登录**：无需设置密码即可直接访问，如需设置密码执行：`jupyter notebook password`
3. **内核名称**：Jupyter内核名称为`Python (全栈办公/数据环境)`，已包含所有预装包
4. **虚拟环境路径**：`/home/你的用户名/python-projects/jupyter-env`

### python-office 功能说明

⚠️ WSL环境下python-office的Windows专属功能不可用，支持的功能如下：

| 支持功能 ✅          | 不支持功能 ❌（仅Windows可用）  |
| ------------------- | ------------------------------ |
| Excel处理 (poexcel) | PPT处理 (poppt) - 需要Office   |
| PDF处理 (popdf)     | Word处理 (poword) - 需要Office |
| 图片处理 (poimage)  | 微信机器人 (PyOfficeRobot)     |
| 文件管理 (pofile)   | 文件搜索 (search4file)         |
| 邮件发送 (poemail)  |                                |
| OCR识别 (poocr)     |                                |
| 视频处理 (povideo)  |                                |
| 网络爬虫 (pospider) |                                |

不支持的功能可以使用LibreOffice等开源工具替代。

## ❓ 常见问题

### Q1：安装过程中提示依赖包安装失败？

A：执行`sudo apt update`更新源后重新运行安装脚本即可，脚本已内置容错逻辑，个别依赖不影响主功能使用。

### Q2：局域网其他设备无法访问？

A：

1. 检查Windows防火墙是否开放8888端口
2. 确认WSL的IP地址是否正确，在WSL中执行`ip addr show eth0`查看inet地址
3. 确认所有设备在同一局域网下

### Q3：如何卸载这个环境？

A：执行以下命令即可完全卸载，无残留：

bash

```
rm -rf ~/python-projects
rm -rf ~/.jupyter
# 删除bash配置中的自动激活代码，编辑~/.bashrc、~/.bash_profile、~/.profile删除Jupyter相关配置
```

### Q4：如何更新脚本功能？

A：下载最新版`install_jupyter.sh`重新执行安装即可，会自动覆盖旧环境。

## 🤝 贡献指南

欢迎提交Issue和PR，你可以：

- 报告使用中遇到的Bug
- 建议新增预装包或功能
- 优化文档说明

## 📄 许可证

MIT License，可自由使用、修改、分发。

## 💬 交流反馈

使用中遇到问题可以提交Issue，或者加入交流群讨论。




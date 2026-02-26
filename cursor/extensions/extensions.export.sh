#!/bin/bash
echo "📦 正在导出 VSCode 插件列表..."
code --list-extensions > extensions.txt
echo "✅ 导出完成！文件：extensions.txt"
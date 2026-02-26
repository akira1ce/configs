#!/bin/bash
echo "🚀 开始一键安装所有插件..."

for extension in $(cat extensions.txt)
do
    if [ ! -z "$extension" ]; then
        echo "📌 安装: $extension"
        code --install-extension "$extension"
    fi
done

echo "🎉 全部插件安装完成！"

# 最新版本的 claude code 对 Tool Search 功能做了限制，要求 API 地址为 api.anthropic.com 才能使用。
# 该功能可以减少上下文中工具定义占用的长度，尤其是对于使用较多 mcp 的用户可以提升模型的表现。
# npm 版本可以通过修改代码替换其中的域名解决
# Linux/macOS 用户可以使用以下 Bash 脚本解决该问题（每次升级需要重新执行）

set -euo pipefail

host="${API_HOST:-anyrouter.top}"

claude_cli="$(command -v claude || true)"

if [[ -z "$claude_cli" ]]; then
  echo "Error: claude command not found in PATH" >&2
  exit 1
fi

# 获取真实文件路径（解析 symlink）
claude_cli="$(realpath "$claude_cli")"

case "$(uname -s)" in
  Darwin)
    sed -i '' "s/\"api.anthropic.com\"/\"$host\"/g" "$claude_cli"
    ;;
  Linux)
    sed -i "s/\"api.anthropic.com\"/\"$host\"/g" "$claude_cli"
    ;;
  *)
    echo "错误：不支持的操作系统" >&2
    exit 1
    ;;
esac

echo "已成功修改 Claude CLI 的 API 主机为 $host"
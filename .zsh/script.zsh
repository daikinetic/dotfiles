
function xcode-select() {
  command xcode-select "$@"      # ① 引数そのまま元コマンドに渡して実行
  echo                           # ② 空行で見やすく
  command xcode-select --help    # ③ 常にヘルプを表示
}

sedbat() {
  sed -n "s/$1/$2/p" | bat
}

function brew() {
  command brew "$@" || return

  if [[ "$1" == "install" && -n "$2" ]]; then
    local tool="$2"

    echo -e "\n✅ [brew install]: $tool"
    echo "────────────────────────────"

    command brew info "$tool" | awk -v tool="$tool" '
      BEGIN {
        deps = 0
      }

      /^==> / {
        if (!seen++) print "🔍 " $0
        next
      }

      /^https?:\/\// {
        printf "🌐 %-12s : %s\n", "Homepage", $0
        next
      }

      /Poured from/ {
        printf "📦 %-12s : %s\n", "Source URL", $0
        next
      }

      /^\/opt/ {
        printf "📁 %-12s : %s\n", "Installed", $0
        next
      }

      /License/ {
        gsub(/^.*License: */, "", $0)
        printf "📝 %-12s : %s\n", "License", $0
        next
      }

      /^==> Dependencies/ {
        deps = 1
        print "\n🔗 Dependencies"
        next
      }

      deps && /^==>/ {
        deps = 0
        next
      }

      deps {
        if ($0 ~ /^Build:/)
          printf "  • %-10s : %s\n", "Build", substr($0, index($0, $2))
        else if ($0 ~ /^Required:/)
          printf "  • %-10s : %s\n", "Required", substr($0, index($0, $2))
        else
          print "  • " $0
        next
      }

      /^install:/ {
        print "\n📊 Analytics"
      }

      /^install-on-request:/ || /^build-error:/ {
        sub(": ", " : ", $0)
        gsub(/\(|\)/, "", $3)
        printf "  • %-16s : %s (%s)\n", $1, $2, $3
        next
      }
    '

    echo -e "\n📘 man excerpt: $tool"
    echo "────────────────────────────"

    man "$tool" 2>/dev/null | col -bx | awk '
      /NAME/,/^$/ {
        if ($0 ~ /^$/) exit
        print "  " $0
      }
    ' || echo "  ⚠️  No man page available"
  fi
}


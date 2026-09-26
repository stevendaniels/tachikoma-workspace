#!/bin/bash
# Dry-run tests for tachikoma-post (no token read, nothing posted). Run inside the container:
#   docker exec picoclaw-gateway bash /workspace/bin/tachikoma-post.test.sh
set -u
P="$(cd "$(dirname "$0")" && pwd)/tachikoma-post"
fail=0
body() { bash "$P" --dry-run "$1" | sed '1,2d'; }
check() {  # name expected actual
  if [ "$2" == "$3" ]; then echo "ok   $1"; else echo "FAIL $1"; echo "  expected: $2"; echo "  actual:   $3"; fail=1; fi
}

check "keeps mrkdwn" "*bold* _it_ \`code\`
• item" "$(printf '*bold* _it_ `code`\n• item' | body email-digest)"
check "escapes mentions" "hi &lt;!channel&gt; &lt;@U123&gt; &lt;#C1&gt;" "$(printf 'hi <!channel> <@U123> <#C1>' | body email-digest)"
check "escapes disguised link" "&lt;https://evil.example|Your bank&gt;" "$(printf '<https://evil.example|Your bank>' | body email-digest)"
check "keeps allow-listed link" "<https://mail.google.com/mail/u/?authuser=a%40b#search/from%3Ax|open>" \
  "$(printf '<https://mail.google.com/mail/u/?authuser=a%%40b#search/from%%3Ax|open>' | body email-digest)"
check "escapes ampersand" "A &amp; B" "$(printf 'A & B' | body email-digest)"
check "strips bidi and control chars" "abcd" "$(printf 'a‮b\x07c​d' | body email-digest)"
check "routes by name" "dest=email-digest channel=C0AS8TH1H37 chars=2" "$(printf 'hi' | bash "$P" --dry-run email-digest | head -1)"
printf '' | bash "$P" --dry-run email-digest >/dev/null 2>&1; check "rejects empty" "2" "$?"
printf 'x' | bash "$P" --dry-run nowhere >/dev/null 2>&1; check "rejects unknown destination" "2" "$?"
head -c 3600 /dev/zero | tr '\0' 'x' | bash "$P" --dry-run email-digest >/dev/null 2>&1; check "rejects over cap" "2" "$?"
exit $fail

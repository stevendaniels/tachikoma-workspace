#!/bin/bash
# Tests for tachikoma-productivity, with a stub agent-courier (nothing is dispatched). Run:
#   bash /workspace/bin/tachikoma-productivity.test.sh
set -u
P="$(cd "$(dirname "$0")" && pwd)/tachikoma-productivity"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/dispatches"
cat >"$T/bin/agent-courier" <<EOF
#!/bin/bash
printf '%s\n' "\$@" >"$T/args"
while [ \$# -gt 0 ]; do [ "\$1" = --body-file ] && cp "\$2" "$T/body"; shift; done
EOF
chmod 755 "$T/bin/agent-courier"
run() { PATH="$T/bin:$PATH" TACHIKOMA_PRODUCTIVITY_DISPATCH_DIR="$T/dispatches" bash "$P" "$@"; }
fail=0
check() {  # name expected actual
  if [ "$2" == "$3" ]; then echo "ok   $1"; else echo "FAIL $1"; echo "  expected: $2"; echo "  actual:   $3"; fail=1; fi
}
arg_after() { awk -v f="$1" 'p { print; exit } $0 == f { p = 1 }' "$T/args"; }

printf 'put the dentist on my calendar next tuesday at 3' | run slack:C0AS8TH1H37/1727460000.000100 >/dev/null
check "body verbatim" "put the dentist on my calendar next tuesday at 3" "$(cat "$T/body")"
check "exec to productivity" "exec productivity" "$(arg_after --delivery-type) $(arg_after --delivery-id)"
check "reply via chat to origin" "chat slack:C0AS8TH1H37/1727460000.000100" "$(arg_after --reply-via) $(arg_after --reply-delivery-id)"
check "dispatch dir" "$T/dispatches" "$(arg_after --dispatch-dir)"

printf '12:30' | run telegram:8612824737 >/dev/null
check "telegram origin" "telegram:8612824737" "$(arg_after --reply-delivery-id)"

rm -f "$T/args"
printf 'x' | run discord:123 >/dev/null 2>&1; check "rejects other channels" "2" "$?"
printf 'x' | run 'slack:C1; rm -rf /' >/dev/null 2>&1; check "rejects odd origin" "2" "$?"
printf ' \n ' | run slack:C1 >/dev/null 2>&1; check "rejects empty" "2" "$?"
head -c 2100 /dev/zero | tr '\0' x | run slack:C1 >/dev/null 2>&1; check "rejects over cap" "2" "$?"
printf 'x' | run >/dev/null 2>&1; check "requires origin" "2" "$?"
check "nothing dispatched on rejection" "no" "$([ -f "$T/args" ] && echo yes || echo no)"
check "dry run" "origin=slack:C1 chars=5" "$(printf 'hello' | run --dry-run slack:C1 | head -1)"
exit $fail

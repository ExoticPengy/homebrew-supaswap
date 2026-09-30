#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")"

export SUPASWAP_SERVICE=supaswap-test SUPASWAP_CLI_SERVICE=supaswap-test-cli SUPASWAP_CLI_ACCOUNT=cli
unset SUPABASE_ACCESS_TOKEN
tmp=$(mktemp -d)
# Stub for `supabase login`: reads token on stdin, stores it where supaswap reads the CLI token.
cat >"$tmp/login" <<'STUB'
#!/bin/sh
read -r tok
printf 'add-generic-password -U -s supaswap-test-cli -a cli -w "%s"\n' "$tok" | security -i >/dev/null
STUB
chmod +x "$tmp/login"
export SUPASWAP_LOGIN="$tmp/login"

wipe() {
  for a in a b; do security delete-generic-password -s supaswap-test -a "$a" >/dev/null 2>&1; done
  security delete-generic-password -s supaswap-test-cli -a cli >/dev/null 2>&1
}
trap 'wipe; rm -rf "$tmp"' EXIT
wipe

fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: expected [$3] got [$2]"; fail=1; fi; }
cli_token() { security find-generic-password -s supaswap-test-cli -a cli -w 2>/dev/null; }
login_as() { echo "$1" | "$SUPASWAP_LOGIN"; }

out=$(./supaswap save a 2>&1); check "save logged out exits 1" "$?" 1
check "save logged out msg" "$out" "not logged in; run supabase login first"

login_as sbp_aaa; ./supaswap save a >/dev/null
login_as sbp_bbb; ./supaswap save b >/dev/null
./supaswap use a >/dev/null; check "use a swaps CLI token" "$(cli_token)" sbp_aaa

out=$(./supaswap use nope 2>&1); check "use unknown exits 1" "$?" 1
check "use unknown msg" "$out" "no saved account: nope"

err=$(SUPABASE_ACCESS_TOKEN=x ./supaswap use b 2>&1 >/dev/null)
check "env var warning" "$err" "warning: SUPABASE_ACCESS_TOKEN is set and overrides the stored login"
check "use b still swaps" "$(cli_token)" sbp_bbb

check "ls marks active" "$(./supaswap ls)" "$(printf '  a\n* b')"
./supaswap use a >/dev/null
check "ls marker moves" "$(./supaswap ls)" "$(printf '* a\n  b')"

login_as sbp_ccc; ./supaswap save b >/dev/null
./supaswap use a >/dev/null; ./supaswap use b >/dev/null
check "save overwrites" "$(cli_token)" sbp_ccc

./supaswap rm a >/dev/null
out=$(./supaswap rm a 2>&1); check "rm twice exits 1" "$?" 1
check "rm twice msg" "$out" "no saved account: a"
check "ls after rm" "$(./supaswap ls)" "* b"

printf 'add-generic-password -U -s supaswap-test-cli -a cli -w "go-keyring-base64:%s"\n' "$(printf sbp_ddd | base64)" | security -i >/dev/null
./supaswap save a >/dev/null; login_as sbp_eee; ./supaswap use a >/dev/null
check "save decodes go-keyring-base64" "$(cli_token)" sbp_ddd

login_as junk; ./supaswap save a >/dev/null 2>&1; check "save rejects non-sbp token" "$?" 1

./supaswap save 'a b' >/dev/null 2>&1; check "bad name exits 1" "$?" 1
./supaswap >/dev/null 2>&1; check "no command exits 1" "$?" 1
for h in help -h --help; do
  out=$(./supaswap $h 2>/dev/null); check "$h exits 0" "$?" 0
  case "$out" in *"save <name>"*"use <name>"*"ls"*"rm <name>"*) r=listed ;; *) r=missing ;; esac
  check "$h lists commands" "$r" listed
done

exit $fail

#!/bin/bash
# Tests for git-diff-filter --no-comments / -nc

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/git-diff-filter"

if [ ! -x "$SCRIPT" ]; then
    echo "FAIL: $SCRIPT not executable"
    exit 1
fi

pass=0
fail=0

assert_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if echo "$haystack" | grep -qF -- "$needle"; then
        pass=$((pass + 1))
        echo "  ok: $msg"
    else
        fail=$((fail + 1))
        echo "  FAIL: $msg"
        echo "    expected to contain: $needle"
        echo "    got:"
        echo "$haystack" | sed 's/^/      /'
    fi
}

assert_not_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if echo "$haystack" | grep -qF -- "$needle"; then
        fail=$((fail + 1))
        echo "  FAIL: $msg"
        echo "    expected NOT to contain: $needle"
        echo "    got:"
        echo "$haystack" | sed 's/^/      /'
    else
        pass=$((pass + 1))
        echo "  ok: $msg"
    fi
}

setup_repo() {
    local dir
    dir=$(mktemp -d)
    cd "$dir" || exit 1
    git init -q -b main
    git config user.email test@test.local
    git config user.name test
    echo "$dir"
}

teardown() {
    cd /
    rm -rf "$1"
}

# ---------------------------------------------------------------------------
echo "test: --no-comments strips // and /* */ in .ts/.js/.cpp"
dir=$(setup_repo)
mkdir -p src
cat > src/a.ts <<'EOF'
export const x = 1;
EOF
cat > src/b.cpp <<'EOF'
int x = 1;
EOF
cat > src/c.js <<'EOF'
const x = 1;
EOF
git add -A && git commit -qm initial

cat > src/a.ts <<'EOF'
// this is a ts comment
export const x = 2;
/* block comment */
export const y = 3;
 * continuation
EOF
cat > src/b.cpp <<'EOF'
// cpp comment
int x = 2;
/* block */
int y = 3;
EOF
cat > src/c.js <<'EOF'
// js comment
const x = 2;
const y = 3;
EOF

out=$("$SCRIPT" HEAD -nc 2>/dev/null)

assert_contains    "$out" "# warning - all comments have been removed" "header warning printed"
assert_not_contains "$out" "// this is a ts comment" "ts // line stripped"
assert_not_contains "$out" "/* block comment */"     "ts /* ... */ stripped"
assert_not_contains "$out" "* continuation"          "ts * continuation stripped"
assert_not_contains "$out" "// cpp comment"          "cpp // line stripped"
assert_not_contains "$out" "/* block */"             "cpp /* */ stripped"
assert_not_contains "$out" "// js comment"           "js // line stripped"
assert_contains    "$out" "export const x = 2"      "ts code kept"
assert_contains    "$out" "int x = 2"               "cpp code kept"
assert_contains    "$out" "const x = 2"             "js code kept"
teardown "$dir"

# ---------------------------------------------------------------------------
echo "test: --no-comments strips # in .py"
dir=$(setup_repo)
cat > a.py <<'EOF'
x = 1
EOF
git add -A && git commit -qm initial

cat > a.py <<'EOF'
# python comment
x = 2
    # indented comment
y = 3
EOF

out=$("$SCRIPT" HEAD --no-comments 2>/dev/null)

assert_contains    "$out" "# warning - all comments have been removed" "header warning printed"
assert_not_contains "$out" "# python comment"   "py # line stripped"
assert_not_contains "$out" "# indented comment" "py indented # stripped"
assert_contains    "$out" "x = 2"               "py code kept"
assert_contains    "$out" "y = 3"               "py code kept"
teardown "$dir"

# ---------------------------------------------------------------------------
echo "test: without --no-comments, comments are preserved"
dir=$(setup_repo)
cat > a.py <<'EOF'
x = 1
EOF
git add -A && git commit -qm initial
cat > a.py <<'EOF'
# python comment
x = 2
EOF
out=$("$SCRIPT" HEAD 2>/dev/null)
assert_contains    "$out" "# python comment" "comment preserved without flag"
assert_not_contains "$out" "# warning - all comments have been removed" "no warning header without flag"
teardown "$dir"

# ---------------------------------------------------------------------------
echo "test: --no-comments leaves non-supported extensions alone"
dir=$(setup_repo)
cat > a.rs <<'EOF'
fn main() {}
EOF
git add -A && git commit -qm initial
cat > a.rs <<'EOF'
// rust comment - not in supported list
fn main() { let x = 1; }
EOF
out=$("$SCRIPT" HEAD -nc 2>/dev/null)
assert_contains "$out" "// rust comment" ".rs comments preserved (not in supported list)"
teardown "$dir"

# ---------------------------------------------------------------------------
echo "test: -nc combines with -e exclude"
dir=$(setup_repo)
cat > a.ts <<'EOF'
const x = 1;
EOF
cat > b.ts <<'EOF'
const y = 1;
EOF
git add -A && git commit -qm initial
cat > a.ts <<'EOF'
// kept-file comment
const x = 2;
EOF
cat > b.ts <<'EOF'
// excluded-file comment
const y = 2;
EOF
out=$("$SCRIPT" HEAD -nc -e b.ts 2>/dev/null)
assert_not_contains "$out" "// kept-file comment"     "comment stripped in included file"
assert_not_contains "$out" "// excluded-file comment" "excluded file not in diff"
assert_contains    "$out" "const x = 2"              "included file content shown"
teardown "$dir"

# ---------------------------------------------------------------------------
echo ""
echo "passed: $pass"
echo "failed: $fail"
[ "$fail" -eq 0 ]

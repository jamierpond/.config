#!/bin/bash
# Tests for git-diff-filter --no-comments / -nc

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/git-diff-filter"
STRIPPER="$SCRIPT_DIR/diff-strip-comments.py"

if [ ! -x "$SCRIPT" ]; then
    echo "FAIL: $SCRIPT not executable"
    exit 1
fi
if [ ! -f "$STRIPPER" ]; then
    echo "FAIL: $STRIPPER missing"
    exit 1
fi

pass=0
fail=0
current_test=""

start_test() {
    current_test="$1"
    echo ""
    echo "test: $current_test"
}

assert_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if echo "$haystack" | grep -qF -- "$needle"; then
        pass=$((pass + 1))
        echo "  ok: $msg"
    else
        fail=$((fail + 1))
        echo "  FAIL [$current_test]: $msg"
        echo "    expected to contain: $needle"
        echo "    got:"
        echo "$haystack" | sed 's/^/      /'
    fi
}

assert_not_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if echo "$haystack" | grep -qF -- "$needle"; then
        fail=$((fail + 1))
        echo "  FAIL [$current_test]: $msg"
        echo "    expected NOT to contain: $needle"
        echo "    got:"
        echo "$haystack" | sed 's/^/      /'
    else
        pass=$((pass + 1))
        echo "  ok: $msg"
    fi
}

assert_eq() {
    local actual="$1" expected="$2" msg="$3"
    if [ "$actual" = "$expected" ]; then
        pass=$((pass + 1))
        echo "  ok: $msg"
    else
        fail=$((fail + 1))
        echo "  FAIL [$current_test]: $msg"
        echo "    expected: $expected"
        echo "    actual:   $actual"
    fi
}

setup_repo() {
    dir=$(mktemp -d)
    cd "$dir" || exit 1
    git init -q -b main
    git config user.email test@test.local
    git config user.name test
}

teardown() {
    cd /
    rm -rf "$dir"
}

# Run the stripper directly on a diff fixture (no git involvement).
strip() {
    "$STRIPPER" <<< "$1"
}

# ===========================================================================
# End-to-end tests via the gd wrapper
# ===========================================================================

start_test "header warning printed only with --no-comments"
setup_repo
echo "x = 1" > a.py
git add -A && git commit -qm initial
echo "x = 2" > a.py
with_flag=$("$SCRIPT" HEAD -nc 2>/dev/null)
without_flag=$("$SCRIPT" HEAD 2>/dev/null)
assert_contains    "$with_flag"    "# warning - all comments have been removed" "header with -nc"
assert_not_contains "$without_flag" "# warning - all comments have been removed" "no header without flag"
teardown

start_test "-nc and --no-comments are both accepted"
setup_repo
cat > a.py <<'EOF'
x = 1
EOF
git add -A && git commit -qm initial
cat > a.py <<'EOF'
# comment
x = 2
EOF
out_short=$("$SCRIPT" HEAD -nc 2>/dev/null)
out_long=$("$SCRIPT" HEAD --no-comments 2>/dev/null)
assert_not_contains "$out_short" "# comment" "-nc strips"
assert_not_contains "$out_long"  "# comment" "--no-comments strips"
teardown

start_test "ts/cpp/js whole-line // and /* */ stripped"
setup_repo
mkdir -p src
echo "export const x = 1;" > src/a.ts
echo "int x = 1;" > src/b.cpp
echo "const x = 1;" > src/c.js
git add -A && git commit -qm initial
cat > src/a.ts <<'EOF'
// ts line comment
export const x = 2;
/* block one-liner */
export const y = 3;
EOF
cat > src/b.cpp <<'EOF'
// cpp line comment
int x = 2;
/* cpp block */
int y = 3;
EOF
cat > src/c.js <<'EOF'
// js comment
const x = 2;
const y = 3;
EOF
out=$("$SCRIPT" HEAD -nc 2>/dev/null)
assert_not_contains "$out" "// ts line comment" "ts // dropped"
assert_not_contains "$out" "/* block one-liner */" "ts /* */ dropped"
assert_not_contains "$out" "// cpp line comment" "cpp // dropped"
assert_not_contains "$out" "/* cpp block */" "cpp /* */ dropped"
assert_not_contains "$out" "// js comment" "js // dropped"
assert_contains    "$out" "export const x = 2" "ts code kept"
assert_contains    "$out" "int x = 2" "cpp code kept"
assert_contains    "$out" "const x = 2" "js code kept"
teardown

start_test "py # line comments stripped"
setup_repo
echo "x = 1" > a.py
git add -A && git commit -qm initial
cat > a.py <<'EOF'
# top comment
x = 2
    # indented comment
y = 3
EOF
out=$("$SCRIPT" HEAD -nc 2>/dev/null)
assert_not_contains "$out" "# top comment" "py # dropped"
assert_not_contains "$out" "# indented comment" "py indented # dropped"
assert_contains    "$out" "x = 2" "py code kept"
assert_contains    "$out" "y = 3" "py code kept"
teardown

start_test "without --no-comments, all comments preserved"
setup_repo
echo "x = 1" > a.py
git add -A && git commit -qm initial
cat > a.py <<'EOF'
# preserve me
x = 2
EOF
out=$("$SCRIPT" HEAD 2>/dev/null)
assert_contains "$out" "# preserve me" "py comment preserved without flag"
teardown

start_test "unsupported extension (.rs) untouched by -nc"
setup_repo
echo "fn main() {}" > a.rs
git add -A && git commit -qm initial
cat > a.rs <<'EOF'
// rust comment
fn main() { let x = 1; }
EOF
out=$("$SCRIPT" HEAD -nc 2>/dev/null)
assert_contains "$out" "// rust comment" ".rs comment passed through"
teardown

start_test "-nc combines with -e exclude"
setup_repo
echo "const x = 1;" > a.ts
echo "const y = 1;" > b.ts
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
assert_not_contains "$out" "// kept-file comment" "comment stripped in included file"
assert_not_contains "$out" "// excluded-file comment" "excluded file absent"
assert_contains    "$out" "const x = 2" "included code kept"
teardown

# ===========================================================================
# Direct stripper tests (precise fixture control)
# ===========================================================================

start_test "regression: multi-line JSDoc added — no orphan /** or */ left"
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -1,3 +1,8 @@
 const before = 1;
+/**
+ * doc body line 1
+ * doc body line 2
+ */
+export const newSym = 2;
 const after = 3;'
out=$(strip "$fixture")
assert_not_contains "$out" "/**" "orphan /** dropped"
assert_not_contains "$out" "doc body line 1" "JSDoc body dropped"
assert_not_contains "$out" "doc body line 2" "JSDoc body dropped"
# Note: the closing */ is fine to test as 'no */ on its own line'
assert_not_contains "$out" "+ */" "added closing */ dropped"
assert_contains    "$out" "+export const newSym = 2;" "added code kept"
assert_contains    "$out" " const before = 1;" "context kept"

start_test "regression: existing JSDoc as context, code added before it"
# This is the EXACT pattern from the bug report. Old awk-based stripper
# would never touch context comment lines, but the user observed the body
# missing while delimiters remained. Validates the new behavior: context
# comments stay whole (no orphans, no missing body).
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -1,5 +1,7 @@
+export const newSym = 1;
+
 /**
  * existing doc body
  */
 export function foo() {}'
out=$(strip "$fixture")
# Context JSDoc is comment-only on both sides → with our rule, it's dropped.
# That removes the misleading "orphan delimiters" effect.
assert_not_contains "$out" " /**"             "context /** dropped"
assert_not_contains "$out" " * existing doc body" "context JSDoc body dropped"
assert_not_contains "$out" "  */"             "context */ dropped"
assert_contains    "$out" "+export const newSym = 1;" "added code kept"
assert_contains    "$out" " export function foo() {}" "non-comment context kept"

start_test "// inside string literal is NOT stripped"
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -1,1 +1,3 @@
 const a = 1;
+const url = "https://example.com/path";
+const s = "// not a comment";'
out=$(strip "$fixture")
assert_contains "$out" 'https://example.com/path' "URL in string kept"
assert_contains "$out" '// not a comment'         "// inside string kept"

start_test "/* inside string is NOT stripped"
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -0,0 +1,1 @@
+const s = "/* not a block comment */";'
out=$(strip "$fixture")
assert_contains "$out" '/* not a block comment */' "/* */ inside string kept"

start_test "// inside template literal is NOT stripped"
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -0,0 +1,1 @@
+const s = `prefix // still in template ${x} suffix`;'
out=$(strip "$fixture")
assert_contains "$out" '// still in template' "// in template kept"

start_test "trailing inline // comment: line kept (has code)"
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -0,0 +1,1 @@
+const x = 1; // trailing'
out=$(strip "$fixture")
assert_contains "$out" "const x = 1;" "line with trailing comment kept (code remains)"

start_test "py: triple-quoted docstring dropped"
fixture='diff --git a/x.py b/x.py
index 0..1 100644
--- a/x.py
+++ b/x.py
@@ -0,0 +1,5 @@
+def f():
+    """docstring line one.
+    docstring line two.
+    """
+    return 1'
out=$(strip "$fixture")
assert_not_contains "$out" "docstring line one"  "docstring body dropped"
assert_not_contains "$out" "docstring line two"  "docstring body dropped"
assert_contains    "$out" "+def f():"            "def kept"
assert_contains    "$out" "+    return 1"        "return kept"

start_test "py: # inside string NOT stripped"
fixture='diff --git a/x.py b/x.py
index 0..1 100644
--- a/x.py
+++ b/x.py
@@ -0,0 +1,2 @@
+s = "not a # comment"
+t = "also not # one"'
out=$(strip "$fixture")
assert_contains "$out" 'not a # comment' "# in py string kept"
assert_contains "$out" 'also not # one'  "# in py string kept"

start_test "py: triple-quoted string used as value (not bare statement) kept"
fixture='diff --git a/x.py b/x.py
index 0..1 100644
--- a/x.py
+++ b/x.py
@@ -0,0 +1,3 @@
+x = """value line one
+value line two
+"""'
out=$(strip "$fixture")
assert_contains "$out" 'value line one' "non-docstring triple kept (line one)"
assert_contains "$out" 'value line two' "non-docstring triple kept (line two)"

start_test "c: removed comment-only lines (- side) are dropped"
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -1,3 +1,1 @@
-// old comment
-const old = 1;
+const new = 1;'
out=$(strip "$fixture")
assert_not_contains "$out" "// old comment" "removed // comment line dropped"
assert_contains    "$out" "-const old = 1;" "removed code kept"
assert_contains    "$out" "+const new = 1;" "added code kept"

start_test "c: removed block-comment lines dropped without orphans"
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -1,5 +1,1 @@
-/**
- * removed doc
- */
-export const old = 1;
+export const new = 1;'
out=$(strip "$fixture")
assert_not_contains "$out" "/**"             "removed /** dropped"
assert_not_contains "$out" "removed doc"     "removed doc body dropped"
assert_not_contains "$out" "- */"            "removed */ dropped"
assert_contains    "$out" "-export const old = 1;" "removed code kept"

start_test "context-only hunk (no +/- comments): unchanged code preserved"
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -1,3 +1,3 @@
 const a = 1;
-const b = 2;
+const b = 22;
 const c = 3;'
out=$(strip "$fixture")
assert_contains "$out" " const a = 1;" "context code preserved"
assert_contains "$out" " const c = 3;" "context code preserved"
assert_contains "$out" "-const b = 2;" "removed code preserved"
assert_contains "$out" "+const b = 22;" "added code preserved"

start_test "binary file diff passes through untouched"
fixture='diff --git a/img.png b/img.png
index 0..1 100644
Binary files a/img.png and b/img.png differ'
out=$(strip "$fixture")
assert_contains "$out" "Binary files a/img.png and b/img.png differ" "binary diff preserved"

start_test "new file mode: header preserved"
fixture='diff --git a/new.ts b/new.ts
new file mode 100644
index 0..1
--- /dev/null
+++ b/new.ts
@@ -0,0 +1,2 @@
+// comment
+const x = 1;'
out=$(strip "$fixture")
assert_contains    "$out" "new file mode 100644" "new file header kept"
assert_not_contains "$out" "// comment"          "comment in new file dropped"
assert_contains    "$out" "+const x = 1;"        "new file code kept"

start_test "deleted file mode: header preserved"
fixture='diff --git a/gone.ts b/gone.ts
deleted file mode 100644
index 0..0
--- a/gone.ts
+++ /dev/null
@@ -1,2 +0,0 @@
-// goodbye comment
-const x = 1;'
out=$(strip "$fixture")
assert_contains    "$out" "deleted file mode 100644" "deleted file header kept"
assert_not_contains "$out" "// goodbye comment"      "deleted comment dropped"
assert_contains    "$out" "-const x = 1;"            "deleted code kept"

start_test "multiple files in one diff handled per-file"
fixture='diff --git a/a.ts b/a.ts
index 0..1 100644
--- a/a.ts
+++ b/a.ts
@@ -0,0 +1,2 @@
+// ts comment
+const a = 1;
diff --git a/b.py b/b.py
index 0..1 100644
--- a/b.py
+++ b/b.py
@@ -0,0 +1,2 @@
+# py comment
+x = 1
diff --git a/c.rs b/c.rs
index 0..1 100644
--- a/c.rs
+++ b/c.rs
@@ -0,0 +1,2 @@
+// rust comment kept
+fn main() {}'
out=$(strip "$fixture")
assert_not_contains "$out" "// ts comment"        "ts comment dropped"
assert_contains    "$out" "+const a = 1;"        "ts code kept"
assert_not_contains "$out" "# py comment"         "py comment dropped"
assert_contains    "$out" "+x = 1"               "py code kept"
assert_contains    "$out" "// rust comment kept" "rust untouched"
assert_contains    "$out" "+fn main() {}"        "rust code kept"

start_test "block comment spanning many lines with code-bearing closer NOT dropped"
# closing `*/` shares its line with code → line has code, must be kept.
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -0,0 +1,4 @@
+const a = 1;
+/* open
+   body */ const b = 2;
+const c = 3;'
out=$(strip "$fixture")
assert_contains    "$out" "+const a = 1;" "code kept"
assert_not_contains "$out" "+/* open"     "pure-comment opener line dropped"
assert_contains    "$out" "const b = 2;" "code after block-comment close kept on its line"
assert_contains    "$out" "+const c = 3;" "code kept"

start_test "extensions accepted: .tsx, .jsx, .mjs, .cjs, .cc, .cxx, .hpp"
for ext in tsx jsx mjs cjs cc cxx hpp; do
    fixture="diff --git a/x.$ext b/x.$ext
index 0..1 100644
--- a/x.$ext
+++ b/x.$ext
@@ -0,0 +1,2 @@
+// $ext comment
+const x = 1;"
    out=$(strip "$fixture")
    if echo "$out" | grep -qF -- "// $ext comment"; then
        fail=$((fail + 1))
        echo "  FAIL [$current_test]: .$ext comment not stripped"
    else
        pass=$((pass + 1))
        echo "  ok: .$ext stripped"
    fi
done

start_test "empty diff in → empty out"
out=$(strip "")
assert_eq "$out" "" "empty input produces empty output"

start_test "diff with no comments unchanged"
fixture='diff --git a/x.ts b/x.ts
index 0..1 100644
--- a/x.ts
+++ b/x.ts
@@ -0,0 +1,1 @@
+const x = 1;'
out=$(strip "$fixture")
expected="$fixture"
assert_eq "$out" "$expected" "comment-free diff round-trips"

# ===========================================================================
echo ""
echo "==========================="
echo "passed: $pass"
echo "failed: $fail"
echo "==========================="
[ "$fail" -eq 0 ]

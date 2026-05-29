#!/usr/bin/env python3
# Strip whole-line comments from a unified diff on stdin.
# Supported: C-family + Python. Trailing inline comments on code lines are left.

from __future__ import annotations

import sys
from dataclasses import dataclass, field


C_EXTS = {"c", "cc", "cpp", "cxx", "h", "hpp", "hh", "ts", "tsx", "js", "jsx", "mjs", "cjs"}
PY_EXTS = {"py"}


def ext_of(path: str) -> str:
    if "." not in path:
        return ""
    return path.rsplit(".", 1)[1].lower()


def lang_of(path: str) -> str:
    e = ext_of(path)
    if e in C_EXTS:
        return "c"
    if e in PY_EXTS:
        return "py"
    return ""


def comment_lines_c(source: list[str]) -> set[int]:
    text = "\n".join(source)
    n = len(text)
    i = 0
    in_comment = bytearray(n)
    state = "code"
    prev_significant = ""

    def can_start_regex() -> bool:
        if not prev_significant:
            return True
        return prev_significant in "([{,;=!&|?:+-*/%~^<>" or prev_significant == "\n"

    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if state == "code":
            if c == "/" and nxt == "/":
                state = "line_comment"
                in_comment[i] = 1
                in_comment[i + 1] = 1
                i += 2
                continue
            if c == "/" and nxt == "*":
                state = "block_comment"
                in_comment[i] = 1
                in_comment[i + 1] = 1
                i += 2
                continue
            if c == "'":
                state = "sq"
                i += 1
                continue
            if c == '"':
                state = "dq"
                i += 1
                continue
            if c == "`":
                state = "bt"
                i += 1
                continue
            if c == "/" and can_start_regex():
                state = "regex"
                i += 1
                continue
            if not c.isspace():
                prev_significant = c
            i += 1
            continue
        if state == "line_comment":
            if c == "\n":
                state = "code"
                i += 1
                continue
            in_comment[i] = 1
            i += 1
            continue
        if state == "block_comment":
            in_comment[i] = 1
            if c == "*" and nxt == "/":
                in_comment[i + 1] = 1
                i += 2
                state = "code"
                continue
            i += 1
            continue
        if state == "sq":
            if c == "\\" and nxt:
                i += 2
                continue
            if c == "'":
                state = "code"
                prev_significant = "'"
            i += 1
            continue
        if state == "dq":
            if c == "\\" and nxt:
                i += 2
                continue
            if c == '"':
                state = "code"
                prev_significant = '"'
            i += 1
            continue
        if state == "bt":
            if c == "\\" and nxt:
                i += 2
                continue
            if c == "$" and nxt == "{":
                i += 2
                depth = 1
                while i < n and depth > 0:
                    if text[i] == "{":
                        depth += 1
                    elif text[i] == "}":
                        depth -= 1
                    i += 1
                continue
            if c == "`":
                state = "code"
                prev_significant = "`"
            i += 1
            continue
        if state == "regex":
            if c == "\\" and nxt:
                i += 2
                continue
            if c == "[":
                i += 1
                while i < n and text[i] != "]":
                    if text[i] == "\\" and i + 1 < n:
                        i += 2
                        continue
                    if text[i] == "\n":
                        state = "code"
                        break
                    i += 1
                continue
            if c == "/":
                state = "code"
                prev_significant = "/"
                i += 1
                while i < n and text[i].isalpha():
                    i += 1
                continue
            if c == "\n":
                state = "code"
            i += 1
            continue

    drop: set[int] = set()
    pos = 0
    for idx, line in enumerate(source, start=1):
        start = pos
        end = pos + len(line)
        pos = end + 1
        if end <= start:
            continue
        all_ws_or_comment = True
        any_non_ws = False
        for k in range(start, end):
            ch = text[k]
            if ch.isspace():
                continue
            any_non_ws = True
            if not in_comment[k]:
                all_ws_or_comment = False
                break
        if any_non_ws and all_ws_or_comment:
            drop.add(idx)
    return drop


def comment_lines_py(source: list[str]) -> set[int]:
    text = "\n".join(source)
    n = len(text)
    in_comment = bytearray(n)
    in_string_statement = bytearray(n)
    i = 0
    state = "code"
    line_start = 0

    def is_blank_or_ws(start: int, end: int) -> bool:
        return all(text[k].isspace() for k in range(start, end))

    while i < n:
        c = text[i]
        if state == "code":
            if c == "\n":
                line_start = i + 1
                i += 1
                continue
            if c == "#":
                while i < n and text[i] != "\n":
                    in_comment[i] = 1
                    i += 1
                continue
            if c in ("'", '"'):
                if text[i : i + 3] in ("'''", '"""'):
                    triple = text[i : i + 3]
                    bare = is_blank_or_ws(line_start, i)
                    if bare:
                        for k in range(i, i + 3):
                            in_string_statement[k] = 1
                    i += 3
                    while i < n:
                        if text[i] == "\\" and i + 1 < n:
                            if bare:
                                in_string_statement[i] = 1
                                in_string_statement[i + 1] = 1
                            i += 2
                            continue
                        if text[i : i + 3] == triple:
                            if bare:
                                for k in range(i, i + 3):
                                    in_string_statement[k] = 1
                            i += 3
                            break
                        if bare:
                            in_string_statement[i] = 1
                        i += 1
                    continue
                quote = c
                i += 1
                while i < n and text[i] != quote:
                    if text[i] == "\\" and i + 1 < n:
                        i += 2
                        continue
                    if text[i] == "\n":
                        break
                    i += 1
                if i < n and text[i] == quote:
                    i += 1
                continue
            i += 1
            continue

    drop: set[int] = set()
    pos = 0
    for idx, line in enumerate(source, start=1):
        start = pos
        end = pos + len(line)
        pos = end + 1
        if end <= start:
            continue
        any_non_ws = False
        all_comment_or_bare = True
        for k in range(start, end):
            ch = text[k]
            if ch.isspace():
                continue
            any_non_ws = True
            if not (in_comment[k] or in_string_statement[k]):
                all_comment_or_bare = False
                break
        if any_non_ws and all_comment_or_bare:
            drop.add(idx)
    return drop


COMMENT_LINES = {
    "c": comment_lines_c,
    "py": comment_lines_py,
}


@dataclass
class FileBlock:
    header_lines: list[str] = field(default_factory=list)
    body_lines: list[str] = field(default_factory=list)
    path: str = ""


def split_into_blocks(lines: list[str]) -> list[FileBlock]:
    blocks: list[FileBlock] = []
    cur: FileBlock | None = None
    in_header = False
    for line in lines:
        if line.startswith("diff --git "):
            if cur is not None:
                blocks.append(cur)
            cur = FileBlock()
            parts = line.rstrip("\n").split(" ")
            if len(parts) >= 4 and parts[-1].startswith("b/"):
                cur.path = parts[-1][2:]
            cur.header_lines.append(line)
            in_header = True
            continue
        if cur is None:
            cur = FileBlock()
            cur.header_lines.append(line)
            continue
        if in_header:
            if line.startswith("@@"):
                in_header = False
                cur.body_lines.append(line)
            elif line.startswith(("index ", "--- ", "+++ ", "new file", "deleted file", "similarity ", "rename ", "copy ", "Binary ")):
                cur.header_lines.append(line)
            elif line.startswith(("+", "-", " ")):
                in_header = False
                cur.body_lines.append(line)
            else:
                cur.header_lines.append(line)
        else:
            cur.body_lines.append(line)
    if cur is not None:
        blocks.append(cur)
    return blocks


def reconstruct_sides(body: list[str]) -> tuple[list[str], list[str], list[tuple[str, int, int]]]:
    old_lines: list[str] = []
    new_lines: list[str] = []
    mapping: list[tuple[str, int, int]] = []
    for raw in body:
        if not raw:
            mapping.append(("", -1, -1))
            continue
        first = raw[0]
        content = raw[1:].rstrip("\n")
        if first == "@":
            mapping.append(("@", -1, -1))
            continue
        if first == "\\":
            mapping.append(("\\", -1, -1))
            continue
        if first == "+":
            new_lines.append(content)
            mapping.append(("+", -1, len(new_lines)))
        elif first == "-":
            old_lines.append(content)
            mapping.append(("-", len(old_lines), -1))
        elif first == " ":
            old_lines.append(content)
            new_lines.append(content)
            mapping.append((" ", len(old_lines), len(new_lines)))
        else:
            mapping.append(("?", -1, -1))
    return old_lines, new_lines, mapping


def filter_block(block: FileBlock) -> list[str]:
    lang = lang_of(block.path)
    if lang == "" or not block.body_lines:
        return block.header_lines + block.body_lines
    old_lines, new_lines, mapping = reconstruct_sides(block.body_lines)
    lexer = COMMENT_LINES[lang]
    drop_old = lexer(old_lines) if old_lines else set()
    drop_new = lexer(new_lines) if new_lines else set()
    out: list[str] = list(block.header_lines)
    for raw, (kind, oidx, nidx) in zip(block.body_lines, mapping):
        if kind == "@" or kind == "\\" or kind == "":
            out.append(raw)
            continue
        if kind == "+":
            if nidx in drop_new:
                continue
            out.append(raw)
            continue
        if kind == "-":
            if oidx in drop_old:
                continue
            out.append(raw)
            continue
        if kind == " ":
            if oidx in drop_old and nidx in drop_new:
                continue
            out.append(raw)
            continue
        out.append(raw)
    return out


def main() -> int:
    data = sys.stdin.read()
    lines = data.splitlines(keepends=True)
    blocks = split_into_blocks(lines)
    out_parts: list[str] = []
    for b in blocks:
        out_parts.extend(filter_block(b))
    sys.stdout.write("".join(out_parts))
    return 0


if __name__ == "__main__":
    sys.exit(main())

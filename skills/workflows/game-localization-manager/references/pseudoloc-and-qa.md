# Pseudo-Localization, Automated Checks and LQA

Read this when setting up pseudo-localization, translation checks in CI, or linguistic QA. The two
scripts below are standard-library Python 3; copy them into the project's `tools/` folder. They were
tested on JSON (flat and nested), CSV, ICU plural strings, printf placeholders, and BBCode/HTML-style
tags.

## 1. Engine-native pseudo-localization first

| Engine | How |
|---|---|
| Godot 4.x | Project Settings (advanced) > `internationalization/pseudolocalization/use_pseudolocalization`, with `expansion_ratio`, `replace_with_accents`, `double_vowels`, `fake_bidi`, `prefix`, `suffix`, `skip_placeholders`; force RTL layout with `internationalization/rendering/force_right_to_left_layout_direction` |
| Unity | Localization package Pseudo-Localization (add a pseudo-locale with methods such as accenting, expansion and bracketing) |
| Unreal | Import a pseudo-localized PO (generated with the script below from an exported PO converted to CSV, or with your TMS) as a test culture; some forum answers mention a `-leet` debug flag, which you should verify for your version |
| Web | The script below on your JSON catalogs, served as a test locale (`en-XA`) behind a query flag |
| PO files generally | Your TMS's pseudo-locale feature, or Translate Toolkit's `podebug` |

## 2. `tools/pseudoloc.py`

```python
#!/usr/bin/env python3
"""Pseudo-localize JSON (flat or nested) or CSV string files.

Usage:
  python3 tools/pseudoloc.py locales/en.json locales/en-XA.json
  python3 tools/pseudoloc.py strings.csv strings_pseudo.csv --column en --out-column en_XA
Placeholders ({name}, {0}, %s, %1$d), ICU plural/select syntax, markup tags (<b>, [color=red])
and escaped newlines are preserved; only literal text is transformed.
"""
import csv, json, re, sys

ACCENTS = str.maketrans("aeiouycnAEIOUYCN", "àéîöüýçñÀÉÎÖÜÝÇÑ")
PROTECT = re.compile(r"""(
    \{\s*\w+\s*,\s*(?:plural|select|selectordinal)\s*,   # ICU head: {count, plural,
  | (?:=\d+|zero|one|two|few|many|other)\s*\{            # ICU branch key: one {
  | \{[\w.]*\}                                           # {name} {0}
  | %(?:\d+\$)?[-+\x200\#]*\d*(?:\.\d+)?[sdifxXc%@]     # printf-style
  | <[^<>]+>                                             # <b> <color=#fff>
  | \[[^\[\]]+\]                                         # [b] [color=red] (BBCode)
  | \}                                                   # ICU closing brace
  | \#                                                   # ICU number sign
  | \\n                                                  # escaped newline
)""", re.X)

def pseudo(text: str) -> str:
    if not text:
        return text
    parts = PROTECT.split(text)
    out = "".join(p if PROTECT.fullmatch(p) else p.translate(ACCENTS) for p in parts if p)
    pad = "~" * max(3, round(len(text) * 0.4))   # ~40% longer; short strings grow more
    return f"[!! {out} {pad} !!]"

def walk(node):
    if isinstance(node, dict):
        return {k: walk(v) for k, v in node.items()}
    if isinstance(node, list):
        return [walk(v) for v in node]
    return pseudo(node) if isinstance(node, str) else node

def main(argv):
    if len(argv) < 2:
        sys.exit(__doc__)
    src, dst = argv[0], argv[1]
    if src.endswith(".json"):
        data = json.load(open(src, encoding="utf-8"))
        json.dump(walk(data), open(dst, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    elif src.endswith(".csv"):
        col = argv[argv.index("--column") + 1] if "--column" in argv else "en"
        out_col = argv[argv.index("--out-column") + 1] if "--out-column" in argv else col + "_XA"
        rows = list(csv.DictReader(open(src, encoding="utf-8", newline="")))
        fields = list(rows[0].keys()) + ([out_col] if out_col not in rows[0] else [])
        with open(dst, "w", encoding="utf-8", newline="") as f:
            w = csv.DictWriter(f, fieldnames=fields)
            w.writeheader()
            for r in rows:
                r[out_col] = pseudo(r.get(col, ""))
                w.writerow(r)
    else:
        sys.exit("Use .json or .csv; for .po files use your TMS or Translate Toolkit's podebug.")

if __name__ == "__main__":
    main(sys.argv[1:])
```

Example output: `"Wave {n} of {total}"` becomes `"[!! Wàvé {n} öf {total} ~~~~~~~~ !!]"`;
`"{count, plural, one {# item} other {# items}}"` keeps its ICU structure and becomes
`"[!! {count, plural, one {# îtém} other {# îtéms}} ~~~~~~~~~~~~~~~~~~ !!]"`.

What to look for in a pseudo build:
- plain English text: a hardcoded string;
- missing `[!!` or `!!]`: truncation or clipping;
- `[!!` in the middle of a sentence: concatenation;
- boxes instead of accented letters: font coverage gaps.

## 3. `tools/loc_check.py`

```python
#!/usr/bin/env python3
"""Check a translation file against its source. Exit 1 on errors (use in CI).

Usage:
  python3 tools/loc_check.py locales/en.json locales/de.json
  python3 tools/loc_check.py strings.csv --source en --target de [--max-col _max_chars]
Checks: missing/extra keys, empty or untranslated values, placeholder and tag parity, max length.
"""
import csv, json, re, sys

PLACEHOLDER = re.compile(r"\{\s*(\w+)[^{}]*|%(?:\d+\$)?[-+ 0#]*\d*(?:\.\d+)?[sdifxXc@]")
TAG = re.compile(r"</?[A-Za-z][^<>]*>|\[/?[A-Za-z_]+(?:=[^\]]*)?\]")

def flatten(node, prefix=""):
    if isinstance(node, dict):
        out = {}
        for k, v in node.items():
            out.update(flatten(v, f"{prefix}{k}."))
        return out
    return {prefix[:-1]: node}

def tokens(rx, s):
    return sorted(m.group(0) if rx is TAG else (m.group(1) or m.group(0)) for m in rx.finditer(s))

def load(argv):
    if argv[0].endswith(".json"):
        src = flatten(json.load(open(argv[0], encoding="utf-8")))
        tgt = flatten(json.load(open(argv[1], encoding="utf-8")))
        return src, tgt, {}
    opt = lambda name, default=None: argv[argv.index(name) + 1] if name in argv else default
    s_col, t_col, m_col = opt("--source", "en"), opt("--target"), opt("--max-col", "_max_chars")
    rows = list(csv.DictReader(open(argv[0], encoding="utf-8", newline="")))
    key = list(rows[0].keys())[0]
    src = {r[key]: r[s_col] for r in rows}
    tgt = {r[key]: r.get(t_col, "") for r in rows}
    lim = {r[key]: int(r[m_col]) for r in rows if (r.get(m_col) or "").isdigit()}
    return src, tgt, lim

def main(argv):
    if len(argv) < 2:
        sys.exit(__doc__)
    src, tgt, limits = load(argv)
    errors, warnings = [], []
    for k, s in src.items():
        t = tgt.get(k)
        if t is None:
            errors.append(f"{k}: missing in target"); continue
        if not isinstance(s, str) or not isinstance(t, str):
            continue
        if not t.strip():
            errors.append(f"{k}: empty translation"); continue
        if t == s and len(s) > 3:
            warnings.append(f"{k}: identical to source (untranslated?)")
        if tokens(PLACEHOLDER, s) != tokens(PLACEHOLDER, t):
            errors.append(f"{k}: placeholders differ {tokens(PLACEHOLDER, s)} -> {tokens(PLACEHOLDER, t)}")
        if tokens(TAG, s) != tokens(TAG, t):
            errors.append(f"{k}: tags differ {tokens(TAG, s)} -> {tokens(TAG, t)}")
        if k in limits and len(t) > limits[k]:
            errors.append(f"{k}: {len(t)} chars > max {limits[k]}")
    for k in tgt.keys() - src.keys():
        warnings.append(f"{k}: extra key not in source")
    for w in warnings:
        print("WARN ", w)
    for e in errors:
        print("ERROR", e)
    print(f"{len(src)} keys, {len(errors)} errors, {len(warnings)} warnings")
    sys.exit(1 if errors else 0)

if __name__ == "__main__":
    main(sys.argv[1:])
```

## 4. CI step

```yaml
      - name: Translation checks
        run: |
          for f in locales/*.json; do
            case "$f" in */en.json|*/en-XA.json) continue;; esac
            python3 tools/loc_check.py locales/en.json "$f"
          done
      - name: Pseudo-locale build input
        run: python3 tools/pseudoloc.py locales/en.json locales/en-XA.json
```

For Godot CSV files run `python3 tools/loc_check.py translations/strings.csv --source en --target de`
per language column; for PO files add `msgfmt --check locale/<lang>.po`. Wire these into the
project pipeline with `game-ci-pipeline`, and add a Playwright or engine screenshot pass of key
screens in the pseudo-locale.

## 5. LQA plan

| Item | Plan |
|---|---|
| Testers | Native speakers living in the market, who play games in the genre |
| Build | Release candidate with all languages; debug overlay that shows string keys on demand |
| Coverage | Every screen, every dialogue path that is reachable, settings, store and error messages, save/load, controller and keyboard prompts |
| Context pack | Same as translators: glossary, style guide, character notes, screenshots |
| Cycles | At least two LQA-and-fix cycles per language; a final regression pass on fixes |
| Exit criteria | No open S1/S2 bugs; S3 bugs triaged with owner and date |

Severity:

| Severity | Meaning | Example |
|---|---|---|
| S1 | Blocks play or is offensive/legal risk | Wrong consent text; slur from a mistranslation; crash on locale switch |
| S2 | Wrong meaning or unreadable | Tutorial instruction says the opposite; text cut mid-word; tofu boxes |
| S3 | Style, consistency, tone | Glossary term inconsistent; register too formal for character |
| S4 | Polish | Punctuation, spacing, capitalization |

Bug report template:

```markdown
**LQA-[lang]-[number]** | Severity: S2 | Language: ja | Build: 0.9.3 (a3f9b2c)
**Key:** tutorial.dash_prompt | **Screen:** Room 1 tutorial overlay (screenshot attached)
**Current:** [text as shown]
**Expected:** [corrected text]
**Reason:** meaning reversed; source says "hold" not "tap"
**Method recorded for this key:** NMT+full post-edit (batch B-014)
```

Recording the translation method on bugs shows whether machine-drafted batches need deeper review;
feed that back into the routing table.

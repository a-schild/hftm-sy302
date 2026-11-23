"""Build PDF handouts from the Markdown course material, using the HFTM Word
template (Vorlage/Vorlage_KleineDokumente.dotx).

Usage (from the repository root):
    python tools/build-exports.py                 # default set (Lektion 01-13, Checklisten)
    python tools/build-exports.py "Lektion 08/Lektion08-REST-API.md" ...

Options (environment variables):
    SY302_TEMPLATE  path to the .dotx (default: Vorlage/Vorlage_KleineDokumente.dotx
                    in the repository or in its parent checkout)
    SY302_AUTHOR    author shown in the page header (default: git user.name)

Requirements:
  * pandoc  (PATH or %LOCALAPPDATA%\\Pandoc\\pandoc.exe)
  * Microsoft Word (Windows, driven via COM through PowerShell) for the PDF export

Pipeline: Markdown --pandoc--> temporary .docx (template styles, header/footer
filled in) --Word--> .pdf. No .docx is kept.

Smart page breaks:
  * headings (Überschrift 1-3) are "keep with next" and "keep lines together"
  * code blocks (Quellcode) are kept together on one page (if they fit)
  * a paragraph introducing a code block / table / list is kept with it
  * list items are not split, table rows do not break across pages,
    the table header row repeats
  * widow/orphan control on all body text
"""
from __future__ import annotations

import datetime as dt
import glob
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

DEFAULT_GLOBS = [
    "Lektion 01/*.md",
    "Lektion 02/*.md",
    "Lektion 03/*.md",
    "Lektion 04/*.md",
    "Lektion 05/*.md",
    "Lektion 06/*.md",
    "Lektion 07/*.md",
    "Lektion 08/*.md",
    "Lektion 09/*.md",
    "Lektion 10/*.md",
    "Lektion 11/*.md",
    "Lektion 12/*.md",
    "Lektion 13/*.md",
    "Checklisten/*.md",
]

LABELS = {
    "de": {"course": "Kurs", "course_name": "SY302 Datenbanken", "author": "Autor",
           "page": "Seite", "changed": "Letzte Änderung:"},
    "fr": {"course": "Cours", "course_name": "SY302 Bases de données", "author": "Auteur",
           "page": "Page", "changed": "Dernière modification:"},
}


# ------------------------------------------------------------------ helpers

def find_pandoc() -> str:
    exe = shutil.which("pandoc")
    if exe:
        return exe
    cand = Path(os.environ.get("LOCALAPPDATA", "")) / "Pandoc" / "pandoc.exe"
    if cand.exists():
        return str(cand)
    sys.exit("pandoc not found")


def find_template() -> Path:
    env = os.environ.get("SY302_TEMPLATE")
    cands = [Path(env)] if env else []
    # repository itself, or the main checkout when running inside .claude/worktrees/<name>
    for base in [ROOT, *ROOT.parents]:
        cands.append(base / "Vorlage" / "Vorlage_KleineDokumente.dotx")
    for c in cands:
        if c.exists():
            return c
    sys.exit("Template Vorlage/Vorlage_KleineDokumente.dotx not found (set SY302_TEMPLATE)")


def author() -> str:
    if os.environ.get("SY302_AUTHOR"):
        return os.environ["SY302_AUTHOR"]
    try:
        return subprocess.run(["git", "config", "user.name"], cwd=ROOT, capture_output=True,
                              text=True, encoding="utf-8", check=True).stdout.strip()
    except Exception:
        return ""


def lang_of(md: Path) -> str:
    n = md.name.lower()
    return "fr" if ("-fr" in n or n.startswith(("lecon", "devoir", "travail"))) else "de"


def last_change(md: Path) -> str:
    """Date of the last commit touching the file, or today if it has local changes."""
    rel = str(md.relative_to(ROOT))
    dirty = subprocess.run(["git", "status", "--porcelain", "--", rel], cwd=ROOT,
                           capture_output=True, text=True).stdout.strip()
    if not dirty:
        out = subprocess.run(["git", "log", "-1", "--format=%cs", "--", rel], cwd=ROOT,
                             capture_output=True, text=True).stdout.strip()
        if out:
            return dt.date.fromisoformat(out).strftime("%d.%m.%Y")
    return dt.date.today().strftime("%d.%m.%Y")


def esc(s: str) -> str:
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


PANDOC = find_pandoc()

KEEP_NEXT = "<w:keepNext/>"
KEEP_LINES = "<w:keepLines/>"
CODE_BG = "E0E0E0"  # background of code blocks: ~12% grey


# ------------------------------------------------------- reference document

def _patch_style(xml: str, style_id: str, extra: str) -> str:
    m = re.search(r'(<w:style [^>]*w:styleId="%s"[^>]*>)(.*?)(</w:style>)' % style_id, xml, re.S)
    if not m:
        return xml
    body = m.group(2)
    if "<w:pPr>" in body:
        body = body.replace("<w:pPr>", "<w:pPr>" + extra, 1)
    elif "<w:pPr/>" in body:
        body = body.replace("<w:pPr/>", "<w:pPr>" + extra + "</w:pPr>", 1)
    elif "<w:rPr>" in body:
        body = body.replace("<w:rPr>", "<w:pPr>" + extra + "</w:pPr><w:rPr>", 1)
    else:
        body += "<w:pPr>" + extra + "</w:pPr>"
    return xml[: m.start(2)] + body + xml[m.end(2):]


EXTRA_STYLES = (
    # tight list items: like "Standard" but compact
    '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact">'
    '<w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/>'
    '<w:pPr><w:spacing w:before="0" w:after="40"/></w:pPr></w:style>'
)


def build_reference(template: Path, dest: Path, lang: str, author_name: str) -> None:
    lab = LABELS[lang]
    with zipfile.ZipFile(template) as zin, zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            name = item.filename
            if name.startswith("[trash]"):
                continue
            data = zin.read(name)
            if name == "[Content_Types].xml":
                data = data.replace(
                    b"wordprocessingml.template.main+xml", b"wordprocessingml.document.main+xml")
            elif name == "word/styles.xml":
                xml = data.decode("utf-8")
                for sid in ["Heading1", "Heading2", "Heading3", "Title"]:
                    xml = _patch_style(xml, sid, KEEP_NEXT + KEEP_LINES)
                xml = _patch_style(xml, "Quellcode", KEEP_LINES + '<w:spacing w:after="160" w:line="240" w:lineRule="auto"/>')
                # code background: light grey (CODE_BG) instead of the template's yellow
                m = re.search(r'<w:style [^>]*w:styleId="Quellcode".*?</w:style>', xml, re.S)
                if m:
                    xml = xml[:m.start()] + re.sub(r'w:fill="[0-9A-Fa-f]{6}"', f'w:fill="{CODE_BG}"', m.group(0)) + xml[m.end():]
                # widow/orphan control for all paragraphs (template switches it off in Normal)
                xml = xml.replace('<w:widowControl w:val="0"/>', "<w:widowControl/>")
                xml = xml.replace("</w:styles>", EXTRA_STYLES + "</w:styles>")
                data = xml.encode("utf-8")
            elif re.match(r"word/header\d+\.xml", name):
                xml = data.decode("utf-8")
                xml = xml.replace("<w:t>Kurs</w:t>", f"<w:t>{esc(lab['course'])}</w:t>")
                xml = re.sub(r"<w:t>&lt;</w:t></w:r>.*?<w:t>&gt;</w:t>",
                             f"<w:t>{esc(lab['course_name'])}</w:t>", xml, count=1, flags=re.S)
                xml = xml.replace("<w:t>Autor</w:t>", f"<w:t>{esc(lab['author'])}</w:t>")
                xml = xml.replace("<w:t>&lt;Vorname Name&gt;</w:t>", f"<w:t>{esc(author_name)}</w:t>")
                data = xml.encode("utf-8")
            zout.writestr(item, data)


# --------------------------------------------------------- post-processing

P_RE = re.compile(r"<w:p(?: [^>]*)?>.*?</w:p>|<w:tbl>.*?</w:tbl>", re.S)

STYLE_MAP = {
    "BodyText": "Fliesstext",
    "FirstParagraph": "Fliesstext",
    "SourceCode": "Quellcode",
    "BlockText": "Quote",
    "Heading4": "Heading3",
    "Heading5": "Heading3",
    "Heading6": "Heading3",
}


def _add_ppr(p: str, extra: str) -> str:
    if "<w:pPr>" in p:
        return p.replace("<w:pPr>", "<w:pPr>" + extra, 1)
    if "<w:pPr/>" in p:
        return p.replace("<w:pPr/>", "<w:pPr>" + extra + "</w:pPr>", 1)
    return re.sub(r"^(<w:p(?: [^>]*)?>)", r"\1<w:pPr>" + extra + "</w:pPr>", p, count=1)


def _fix_document(xml: str) -> str:
    for src, dst in STYLE_MAP.items():
        xml = re.sub(r'<w:pStyle w:val="%s"\s*/>' % src, f'<w:pStyle w:val="{dst}"/>', xml)
    xml = re.sub(r'<w:tblStyle w:val="Table"\s*/>', '<w:tblStyle w:val="HFTMTabelle"/>', xml)

    blocks = list(P_RE.finditer(xml))
    is_item = ["<w:numPr>" in b.group(0) and not b.group(0).startswith("<w:tbl>") for b in blocks]
    # size of the contiguous list each list item belongs to
    list_size = [0] * len(blocks)
    i = 0
    while i < len(blocks):
        if is_item[i]:
            j = i
            while j < len(blocks) and is_item[j]:
                j += 1
            for k in range(i, j):
                list_size[k] = j - i
            i = j
        else:
            i += 1

    out, pos = [], 0
    for i, m in enumerate(blocks):
        out.append(xml[pos:m.start()])
        blk = m.group(0)
        nxt = blocks[i + 1].group(0) if i + 1 < len(blocks) else ""
        if blk.startswith("<w:tbl>"):
            blk = re.sub(r"<w:tr>(?!<w:trPr>)", "<w:tr><w:trPr><w:cantSplit/></w:trPr>", blk)
            blk = blk.replace("<w:trPr>", "<w:trPr><w:cantSplit/>").replace(
                "<w:cantSplit/><w:cantSplit/>", "<w:cantSplit/>")
            # first row = header row, repeated on every page
            if "<w:tblHeader" not in blk:
                blk = blk.replace("<w:trPr><w:cantSplit/>", "<w:trPr><w:cantSplit/><w:tblHeader/>", 1)
            # short tables (<= 15 rows) are kept on one page: every row except
            # the last is "keep with next"
            rows = re.findall(r"<w:tr>.*?</w:tr>", blk, re.S)
            if len(rows) <= 15:
                for row in rows[:-1]:
                    new_row = re.sub(r"<w:p>(?!<w:pPr>)", "<w:p><w:pPr>" + KEEP_NEXT + "</w:pPr>", row)
                    new_row = re.sub(r"<w:pPr>(?!<w:keepNext/>)", "<w:pPr>" + KEEP_NEXT, new_row)
                    blk = blk.replace(row, new_row, 1)
        else:
            nxt_is_code = 'w:val="Quellcode"' in nxt
            nxt_is_table = nxt.startswith("<w:tbl>")
            nxt_is_list = "<w:numPr>" in nxt
            text = "".join(re.findall(r"<w:t(?: [^>]*)?>([^<]*)</w:t>", blk)).strip()
            intro = text.endswith(":")
            if (nxt_is_code or nxt_is_table or (intro and nxt_is_list)) and KEEP_NEXT not in blk:
                blk = _add_ppr(blk, KEEP_NEXT)
            if is_item[i] and KEEP_LINES not in blk:
                blk = _add_ppr(blk, KEEP_LINES)
            # short lists (<= 12 items, e.g. a checklist section) stay together
            if is_item[i] and i + 1 < len(blocks) and is_item[i + 1] and list_size[i] <= 12 \
                    and KEEP_NEXT not in blk:
                blk = _add_ppr(blk, KEEP_NEXT)
        out.append(blk)
        pos = m.end()
    out.append(xml[pos:])
    return "".join(out)


RUN_RE = re.compile(r"<w:r(?: [^>]*)?>.*?</w:r>|<w:r(?: [^>]*)?/>", re.S)


def _replace_fields(xml: str, values: dict[str, str]) -> str:
    """Replace complex fields (begin/instr/separate/result/end runs) whose
    instruction starts with one of the keys by a plain text run."""
    runs = list(RUN_RE.finditer(xml))
    out, pos, i = [], 0, 0
    while i < len(runs):
        r = runs[i]
        if 'w:fldCharType="begin"' not in r.group(0):
            i += 1
            continue
        depth, j, instr = 0, i, ""
        while j < len(runs):
            g = runs[j].group(0)
            if 'w:fldCharType="begin"' in g:
                depth += 1
            instr += "".join(re.findall(r"<w:instrText[^>]*>([^<]*)</w:instrText>", g))
            if 'w:fldCharType="end"' in g:
                depth -= 1
                if depth == 0:
                    break
            j += 1
        key = instr.strip().split(" ")[0].upper() if instr.strip() else ""
        if key in values:
            out.append(xml[pos:r.start()])
            out.append(f'<w:r><w:t xml:space="preserve">{esc(values[key])}</w:t></w:r>')
            pos = runs[j].end()
        i = j + 1
    out.append(xml[pos:])
    return "".join(out)


def _fix_footer(xml: str, pdf_name: str, date: str, lang: str) -> str:
    lab = LABELS[lang]
    xml = _replace_fields(xml, {"FILENAME": pdf_name, "SAVEDATE": date})
    xml = re.sub(r"(<w:t(?: [^>]*)?>)Seite", r"\g<1>" + esc(lab["page"]), xml)
    # "Letzte Änderung:" is split into the runs "L" + "etzte Änderung: " in the template
    xml = re.sub(r"(<w:t(?: [^>]*)?>)L</w:t>(.*?)(<w:t(?: [^>]*)?>)etzte Änderung:",
                 r"\g<1></w:t>\g<2>\g<3>" + esc(lab["changed"]), xml, count=1, flags=re.S)
    return xml


def postprocess_docx(path: Path, pdf_name: str, date: str, lang: str) -> None:
    tmp = path.with_suffix(".tmp.docx")
    with zipfile.ZipFile(path) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if item.filename == "word/document.xml":
                data = _fix_document(data.decode("utf-8")).encode("utf-8")
            elif re.match(r"word/footer\d+\.xml", item.filename):
                data = _fix_footer(data.decode("utf-8"), pdf_name, date, lang).encode("utf-8")
            zout.writestr(item, data)
    os.replace(tmp, path)


# ------------------------------------------------------------------- build

WORD_PS = r"""
$ErrorActionPreference = 'Stop'
$jobs = Get-Content -LiteralPath $args[0] -Encoding UTF8
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
try {
  foreach ($line in $jobs) {
    if (-not $line) { continue }
    $src, $dst = $line -split "`t"
    $doc = $word.Documents.Open($src, $false, $true)
    foreach ($story in $doc.StoryRanges) { $null = $story.Fields.Update() }
    $doc.Repaginate()
    $doc.ExportAsFixedFormat($dst, 17, $false, 0, 0, 1, 1, 0, $true, $true, 1)
    $doc.Close([ref]0)
    Write-Output "PDF $dst"
  }
} finally {
  $word.Quit()
  [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
}
"""


def main(argv: list[str]) -> None:
    os.chdir(ROOT)
    files = [Path(a) for a in argv] if argv else sorted(
        {Path(f) for g in DEFAULT_GLOBS for f in glob.glob(g)})
    files = [(ROOT / f).resolve() for f in files]
    template = find_template()
    who = author()

    with tempfile.TemporaryDirectory(prefix="sy302-export-") as td:
        work = Path(td)
        refs = {}
        for lang in LABELS:
            refs[lang] = work / f"reference-{lang}.docx"
            build_reference(template, refs[lang], lang, who)

        jobs = []
        for md in files:
            lang = lang_of(md)
            pdf = md.with_suffix(".pdf")
            docx = work / (md.stem + ".docx")
            subprocess.run(
                [PANDOC, str(md), "-f", "gfm+hard_line_breaks", "-t", "docx", "--reference-doc", str(refs[lang]),
                 "-M", f"lang={'fr-CH' if lang == 'fr' else 'de-CH'}", "-o", str(docx)],
                check=True,
            )
            postprocess_docx(docx, pdf.name, last_change(md), lang)
            jobs.append(f"{docx}\t{pdf}")

        joblist = work / "jobs.txt"
        joblist.write_text("\n".join(jobs), encoding="utf-8")
        script = work / "export.ps1"
        script.write_text(WORD_PS, encoding="utf-8-sig")
        subprocess.run(["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass",
                        "-File", str(script), str(joblist)], check=True)


if __name__ == "__main__":
    main(sys.argv[1:])

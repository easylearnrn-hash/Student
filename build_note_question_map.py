#!/usr/bin/env python3
"""Scan Notes/ into a note catalog and map test questions to notes.

Read-only against the repo and the database. Writes review artifacts and SQL
files to an output directory; nothing is applied to Supabase by this script.
Schema: TEST/MIGRATION-NOTE-QUESTION-MAPPING.sql

  python3 build_note_question_map.py catalog --out DIR
"""
import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import uuid
from html.parser import HTMLParser

ROOT = os.path.dirname(os.path.abspath(__file__))
NOTES_DIR = os.path.join(ROOT, "Notes")
NOTE_ID_NAMESPACE = uuid.UUID("6f1c0a52-3b7e-4c0e-9a55-2f4f0a1d7c10")

# Folders under Notes/ that are not study notes for the test taxonomy.
SKIP_DIRS = {"css", "js", "images"}
BLOCK_TAGS = {"p", "li", "td", "th", "div", "h1", "h2", "h3", "h4", "tr", "section", "header", "ul", "ol", "table", "br"}


class NoteParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.title = ""
        self.h1 = ""
        self.subtitle = ""
        self.tag = ""
        self.headings = []
        self.heading_pos = []  # (block index, text): which block holds each heading
        self.blocks = []
        self._stack = []
        self._buf = []
        self._cur_heading = None
        self._skip = 0

    def _flush(self):
        text = re.sub(r"\s+", " ", "".join(self._buf)).strip()
        self._buf = []
        if text:
            self.blocks.append(text)
        return text

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        cls = (a.get("class") or "").split()
        if tag in ("script", "style"):
            self._skip += 1
        if tag in BLOCK_TAGS:
            self._flush()
        self._stack.append((tag, cls))
        if self._cur_heading is not None and tag not in ("h1", "h2", "h3"):
            self._cur_heading[1].append("\x1f")  # boundary between a title and its subtitle span
        if tag in ("h1", "h2", "h3") or "section-title" in cls:
            self._cur_heading = (tag, [])

    def handle_endtag(self, tag):
        if tag in ("script", "style") and self._skip:
            self._skip -= 1
        while self._stack:
            t, cls = self._stack.pop()
            if t == tag:
                break
        if self._cur_heading is not None and (tag in ("h1", "h2", "h3") or tag == "div"):
            htag, parts = self._cur_heading
            raw = "".join(parts)
            text = re.sub(r"\s+", " ", raw.split("\x1f")[0]).strip()
            sub = re.sub(r"\s+", " ", " ".join(raw.split("\x1f")[1:])).strip()
            if text and (tag == htag or tag == "div"):
                if htag == "h1" and not self.h1:
                    self.h1 = text
                    self.subtitle = sub
                elif text not in self.headings:
                    self.headings.append(text)
                if text not in (h for _, h in self.heading_pos[-1:]):
                    self.heading_pos.append((len(self.blocks), text))
                self._cur_heading = None
        if tag in BLOCK_TAGS:
            self._flush()

    def handle_data(self, data):
        if self._skip:
            return
        in_title = any(t == "title" for t, _ in self._stack)
        if in_title:
            self.title += data
            return
        if any(t == "div" and "note-tag" in c for t, c in self._stack):
            self.tag += data
        if self._cur_heading is not None:
            self._cur_heading[1].append(data)
        self._buf.append(data)


def norm(s):
    s = (s or "").lower()
    s = s.replace("\u2013", "-").replace("\u2014", "-").replace("\u2019", "'").replace("&", " and ")
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9<>%.\- ]+", " ", s)).strip()


def slug(s):
    return re.sub(r"-+", "-", re.sub(r"[^a-z0-9]+", "-", (s or "").lower())).strip("-")


def parse_note(abs_path):
    raw = open(abs_path, "rb").read()
    p = NoteParser()
    p.feed(raw.decode("utf-8", errors="replace"))
    p._flush()
    page_title = re.split(r"\s*\|\s*", p.title.strip())[0]
    title = (p.h1 or page_title or os.path.splitext(os.path.basename(abs_path))[0]).strip()
    subtitle = p.subtitle
    # An <h1> split by <br> ("Cognitive Impairments &<br>Attention Disorders") reads as a dangling
    # connector; the second line is part of the title, not a subtitle.
    if re.search(r"(?:&|/|\+|,|\band|\bor)\s*$", title, re.I) and subtitle:
        title, subtitle = (title + " " + subtitle).strip(), ""
    return {
        "title": title,
        "subtitle": subtitle,
        "tag": re.sub(r"\s+", " ", p.tag).strip(),
        "headings": p.headings,
        "heading_pos": p.heading_pos,
        "blocks": p.blocks,
        "sha256": hashlib.sha256(raw).hexdigest(),
        "bytes": len(raw),
    }


def scan_notes():
    """Return catalog rows (no DB ids resolved) for every Notes/**/*.html."""
    rows = []
    for dirpath, dirnames, filenames in os.walk(NOTES_DIR):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_DIRS)
        for fn in sorted(filenames):
            if not fn.lower().endswith(".html"):
                continue
            abs_path = os.path.join(dirpath, fn)
            rel = os.path.relpath(abs_path, ROOT).replace(os.sep, "/")
            parts = rel.split("/")  # Notes/<System>/[<sub>/]<file>
            info = parse_note(abs_path)
            info.update({
                "path": rel,
                "system_folder": parts[1] if len(parts) > 2 else "",
                "is_subnote": len(parts) > 3,
                "file_stem": os.path.splitext(fn)[0],
            })
            rows.append(info)
    return rows


def stable_note_id(path):
    return str(uuid.uuid5(NOTE_ID_NAMESPACE, "arnoma-note:" + path))


def db_rows(sql):
    """Run a read-only SELECT against the linked Supabase project."""
    assert sql.lstrip().lower().startswith(("select", "with")), "read-only helper"
    p = subprocess.run(["supabase", "db", "query", "--linked", "--agent=yes", "-o", "json", sql],
                       cwd=ROOT, capture_output=True, text=True)
    if p.returncode:
        raise SystemExit("supabase CLI failed: " + (p.stderr or p.stdout)[-400:])
    return json.loads(p.stdout[p.stdout.find("{"):p.stdout.rfind("}") + 1])["rows"]


# Test subject name -> Notes/ folders that hold its notes.
SUBJECT_FOLDERS = {
    "Cardiovascular System": ["Cardiovascular System"],
    "Respiratory System": ["Respiratory System"],
    "Neurology": ["Neurology"],
    "Gastrointestinal & Hepatic System": ["Gastrointestinal & Hepatic System"],
    "Renal": ["Renal System"],
    "Endocrine System": ["Endocrine System"],
    "Musculoskeletal Disorders": ["MusculoskeletalDisorders"],
    "Burns and Skin": ["Burns and Skin"],
    "Autoimmune & Infectious Disorders": ["Autoimmune & Infectious Disorders", "Infections"],
    "Cancer": ["Cancer"],
    "Reproductive and Sexual Health System": ["ReproductiveHealth"],
    "EENT": ["EENT"],
    "Eye Disorders": ["EyeDisorders"],
    "Mental Health": ["MentalHealth"],
    "Maternal Health": ["Maternal Health"],
    "Pediatrics": ["Pediatrics"],
    "Pharmacology": ["Pharmacology"],
    "Nursing Skills and Fundamentals": ["Fundamentals", "Procedures", "NCLEX Prep", "NCLEX-CheatSheet"],
    "Fluids, Electrolytes & Nutrition": ["Fluids, Electrolytes & Nutrition"],
    "Medical-Surgical Care": ["MedSurg"],
    "Psycho-Social Aspects": ["PsychoSocialAspects"],
    "Medical Terminology": ["MedicalTerminology"],
}

STOP = {"and", "the", "of", "in", "to", "a", "nursing", "nclex", "notes", "note", "for", "with", "vs"}

# Topic rows whose name differs from the note title, checked against the note text
# (terms present in the note: Vital-Signs 'Organ Perfusion Priorities'; Cardiac-Biomarkers lists
# troponin/BNP/CK-MM/CK-MB/CK-BB/BUN). 'Shock Management & Emergency Care' was checked and left
# unmapped on purpose: the Shock-Management note has no emergency-care content.
MANUAL_TOPIC_NOTES = {
    ("Cardiovascular System", "Vital Signs and Organ Prioritization"): "Notes/Cardiovascular System/Vital-Signs.html",
    ("Cardiovascular System", "Troponin, BNP, CK-MM, CK-MB, CK-BB, and BUN"): "Notes/Cardiovascular System/Cardiac-Biomarkers.html",
    # Topic name = the note's title plus a decoration ("& Risk Factors", a plural, a typo). One note, one topic.
    ("Cancer", "GI Cancers & Risk Factors"): "Notes/Cancer/GI-Cancers.html",
    ("Cancer", "Hematological (Blood) Cancers & Risk Factors"): "Notes/Cancer/Hematological-Cancers.html",
    ("Cancer", "Large Organ Cancers & Risk Factors"): "Notes/Cancer/Large-Organ-Cancers.html",
    ("Cancer", "Male Reproductive Cancers & Risk Factors"): "Notes/Cancer/Male-Reproductive-Cancers.html",
    ("Endocrine System", "Thyroid Gland and Its Hormones"): "Notes/Endocrine System/Thyroid-Gland-and-Hormones.html",
    ("Fluids, Electrolytes & Nutrition", "Electrolyte Imbalances Overview"): "Notes/Fluids, Electrolytes & Nutrition/Electrolyte-Imbalances.html",
    ("Gastrointestinal & Hepatic System", "Peptic Ulcer Disease (PUD) & Gastritis"): "Notes/Gastrointestinal & Hepatic System/PUD-and-Gastritis.html",
    ("Medical-Surgical Care", "Med-Surge Priorities"): "Notes/MedSurg/MedSurg-Priorities.html",
    ("Mental Health", "3.5  Personality Disorders"): "Notes/MentalHealth/Personality-Disorders.html",
    ("Neurology", "Vertigo & Menieres Disease"): "Notes/Neurology/Vertigo-Menieres.html",
    ("Nursing Skills and Fundamentals", "Documentation"): "Notes/Fundamentals/documentation-informatics-nursing.html",
    ("Nursing Skills and Fundamentals", "Maslow's Hierarchy in Nursing Care"): "Notes/Fundamentals/maslows-hierarchy-nursing.html",
    ("Nursing Skills and Fundamentals", "Tag Colors"): "Notes/Fundamentals/emergency-triage-tag-colors-nursing.html",
    ("Pediatrics", "Pediatric Fever, Dehydration & Phenylketonuria  NCLEX Overview"): "Notes/Pediatrics/Pediatric-Fever-Dehydration-PKU.html",
    ("Pharmacology", "Burns &  Dermatology Meds"): "Notes/Pharmacology/Burns-Dermatology-Medications.html",
    ("Pharmacology", "Infectious Diseases Medication"): "Notes/Pharmacology/Infectious-Diseases-Medications.html",
    ("Pharmacology", "Renal & Urinary Medication"): "Notes/Pharmacology/Renal-Urinary-Medications.html",
    ("Pharmacology", "Fluids, Electrolytes, Acid-Base & IV Therapy Medications"): "Notes/Pharmacology/Fluids-Electrolytes-IV-Therapy.html",
    ("Renal", "1. Urinary Tract Infections (UTI)"): "Notes/Renal System/Urinary-Tract-Infections.html",
    ("Renal", "Acute Renal Failure (ARF) _ Acute Kidney Injury (AKI)"): "Notes/Renal System/Acute-Kidney-Injury.html",
}
# Deliberately NOT mapped (needs a person): two notes cover one topic (Spinal Cord Injury, Therapeutic
# Relationships, Nephrotic Syndrome + Glomerulonephritis), the note does not exist (Respiratory Medications,
# Human Anatomy, Medication suffixes), or the topic spans several notes (EENT overview, Female reproductive).


def tokens(s):
    s = norm(s).replace("-", " ").replace(".", " ")
    return {t for t in s.split() if t and t not in STOP}


def portal_alias_map():
    """title-key -> Notes path, read from the portal's HTML_NOTES_MAP so both stay consistent."""
    src = open(os.path.join(ROOT, "student-portal.html"), encoding="utf-8", errors="replace").read()
    start = src.find("const HTML_NOTES_MAP")
    block = src[start:src.find("};", start)]
    return {k.strip(): v for k, v in re.findall(r"'([^']+)':\s*'(Notes/[^']+\.html)'", block)}


def topic_variants(name):
    """'CPR (Cardiopulmonary Resuscitation)' -> full name, name without the parenthetical, and the parenthetical."""
    out = {name}
    m = re.match(r"^(.*?)\s*\(([^)]+)\)\s*$", name)
    if m:
        out.update({m.group(1), m.group(2)})
    out.add(re.sub(r"^\d+\.\s*", "", name))
    return [v for v in out if v.strip()]


def match_topic(topic_name, candidates, alias_paths):
    """Return (method, score, note) for the best note among candidates (same-system notes)."""
    variants = topic_variants(topic_name)
    by_path = {c["path"]: c for c in candidates}
    # 1. portal alias map (what students already open today)
    for v in variants:
        a = alias_paths.get(norm(v).replace("-", " "))
        if a and a in by_path:
            return "portal_alias", 1.0, by_path[a]
    best = (None, 0.0, None)
    for v in variants:
        key, tset = " ".join(sorted(tokens(v))), tokens(v)
        for c in candidates:
            for label in (c["title"], c["file_stem"].replace("-", " ")):
                ls = tokens(label)
                if not ls or not tset:
                    continue
                if " ".join(sorted(ls)) == key:
                    return "exact_title", 1.0, c
                score = len(tset & ls) / max(len(tset | ls), 1)
                if score > best[1]:
                    best = ("fuzzy", score, c)
    if best[1] >= 0.6:
        return best
    return ("none", best[1], best[2])



# ---------------------------------------------------------------------------
# Automated lexical support check (NOT a clinical review).
# ---------------------------------------------------------------------------
QUALIFIER_RE = re.compile(r"\s*(?:\(?\s*(?:in this note|per (?:this )?note|according to (?:this|the) note)\s*\)?)\.?\s*$", re.I)
NUM_RE = re.compile(r"[<>\u2264\u2265]?\s?\d+(?:\.\d+)?(?:\s?[-\u2013\u2014]\s?\d+(?:\.\d+)?)?\s?%?")
WEAK = {"is", "are", "be", "by", "as", "at", "on", "it", "its", "this", "that", "than", "from", "may", "can", "will",
        "not", "only", "also", "when", "which", "who", "has", "have", "had", "all", "any", "does", "do", "per", "into"}


def strip_qualifier(text):
    t = QUALIFIER_RE.sub("", text or "").strip()
    return t if t.endswith((".", "?", "!")) else t + "."


def stem(w):
    for suf in ("ations", "ation", "ings", "ing", "edly", "ed", "es", "s"):
        if len(w) > len(suf) + 3 and w.endswith(suf):
            return w[: -len(suf)]
    return w


def num_tokens(text):
    out = set()
    for m in NUM_RE.findall((text or "").lower()):
        n = re.sub(r"\s+", "", m.replace("\u2013", "-").replace("\u2014", "-"))
        if re.search(r"\d", n):
            out.add(n)
    return out


def word_tokens(text):
    t = norm(text).replace("-", " ")
    return {stem(w) for w in re.findall(r"[a-z]{2,}", t) if w not in WEAK and w not in STOP and w not in {"or", "if", "so", "no", "an", "we"}}


class NoteIndex:
    def __init__(self, note):
        self.blocks = note["blocks"]
        self.text_words = set()
        self.text_nums = set()
        self.block_words = []
        for b in self.blocks:
            w = word_tokens(b)
            self.block_words.append(w)
            self.text_words |= w
            self.text_nums |= num_tokens(b)
        self.flat = " ".join(norm(b) for b in self.blocks)
        self.heading_pos = sorted(note.get("heading_pos", []))
        # sliding windows of up to 4 adjacent blocks: headings and their list items live in separate blocks
        self.windows = []
        for i in range(len(self.block_words)):
            acc = set()
            for j in range(i, min(i + 4, len(self.block_words))):
                acc |= self.block_words[j]
                self.windows.append((i, j, set(acc)))

    def section_for(self, block_idx):
        """Nearest heading at or before block_idx (None when the note has no headings)."""
        found = None
        for pos, text in self.heading_pos:
            if pos <= block_idx:
                found = text
            else:
                break
        return found

    def score(self, statement):
        st = strip_qualifier(statement)
        w, n = word_tokens(st), num_tokens(st)
        if not w:
            return {"words": 0.0, "nums": 1.0, "best": 0.0, "block": "", "section": None}
        wc = len(w & self.text_words) / len(w)
        nc = 1.0 if not n else len(n & self.text_nums) / len(n)
        best, bi, bj = 0.0, -1, -1
        for i, j, ww in self.windows:
            ov = len(w & ww) / len(w)
            if ov > best or (ov == best and ov > 0 and (j - i) < (bj - bi)):
                best, bi, bj = ov, i, j
        ctx = " | ".join(self.blocks[bi:bj + 1])[:200] if bi >= 0 else ""
        return {"words": round(wc, 2), "nums": round(nc, 2), "best": round(best, 2), "block": ctx,
                "section": self.section_for(bi) if bi >= 0 and best >= 0.5 else None}


def classify(correct_scores, wrong_scores):
    """Question-level verdict from per-option scores."""
    if not correct_scores:
        return "unsupported", []
    flags = []
    cw = min(s["best"] for s in correct_scores)
    cn = min(s["nums"] for s in correct_scores)
    if cw >= 0.75 and cn >= 1.0:
        verdict = "supported"
    elif cw >= 0.5 and cn >= 0.5:
        verdict = "partial"
    else:
        verdict = "unsupported"
    for s in wrong_scores:
        if s["best"] >= 0.85 and s["nums"] >= 1.0:
            flags.append("distractor_matches_note")
            break
    return verdict, flags


def cmd_support(args):
    catalog = {c["note_id"]: c for c in json.load(open(os.path.join(args.out, "note_catalog.json"), encoding="utf-8"))}
    tmap = {t["topic_id"]: t for t in json.load(open(os.path.join(args.out, "topic_note_map.json"), encoding="utf-8"))}
    qs = json.load(open(args.questions, encoding="utf-8"))
    idx = {}
    results = []
    for q in qs:
        t = tmap.get(q["topic_id"])
        nid = t["note_id"] if t else None
        if not nid:
            results.append({"question_id": q["id"], "note_id": None, "verdict": "no_note", "flags": [], "options": []})
            continue
        if nid not in idx:
            idx[nid] = NoteIndex(catalog[nid])
        key = json.loads(q["correct_answer"])
        opts = []
        cs, ws = [], []
        for o in q["options"]:
            sc = idx[nid].score(o["text"])
            sc.update({"id": o["id"], "correct": o["id"] in key, "text": o["text"]})
            opts.append(sc)
            (cs if sc["correct"] else ws).append(sc)
        verdict, flags = classify(cs, ws)
        results.append({"question_id": q["id"], "note_id": nid, "verdict": verdict, "flags": flags, "options": opts,
                        "category": q["category"]})
    out = os.path.join(args.out, "question_support.json")
    json.dump(results, open(out, "w", encoding="utf-8"), ensure_ascii=False)
    from collections import Counter
    print("questions:", len(results), dict(Counter(r["verdict"] for r in results)))
    print("flag distractor_matches_note:", sum("distractor_matches_note" in r["flags"] for r in results))
    print("->", out)


def cmd_topics(args):
    catalog = json.load(open(os.path.join(args.out, "note_catalog.json"), encoding="utf-8"))
    by_path_all = {c["path"]: c for c in catalog}
    aliases = portal_alias_map()
    subjects = {s["id"]: s for s in db_rows("select id, name, display_order from test_subjects order by display_order")}
    topics = db_rows("select t.id, t.subject_id, t.name, t.display_order, t.status, "
                     "(select count(*) from test_questions q where q.topic_id = t.id and q.is_active) as n_questions "
                     "from test_topics t order by t.subject_id, t.display_order, t.name")
    result = []
    for t in topics:
        subj = subjects[t["subject_id"]]["name"]
        folders = SUBJECT_FOLDERS.get(subj, [])
        cands = [c for c in catalog if c["system_folder"] in folders and not c["is_subnote"]]
        manual = MANUAL_TOPIC_NOTES.get((subj, t["name"]))
        if manual and manual in by_path_all:
            method, score, note = "manual_review", 1.0, by_path_all[manual]
        else:
            method, score, note = match_topic(t["name"], cands, aliases)
        result.append({"topic_id": t["id"], "subject": subj, "topic": t["name"], "n_questions": int(t["n_questions"]),
                       "status": t["status"], "method": method, "score": round(score, 2),
                       "note_id": note["note_id"] if note and method != "none" else None,
                       "note_title": note["title"] if note else None, "note_path": note["path"] if note else None})
    json.dump(result, open(os.path.join(args.out, "topic_note_map.json"), "w", encoding="utf-8"), ensure_ascii=False)
    from collections import Counter
    print("topics:", len(result), dict(Counter(r["method"] for r in result)))
    print("topics WITH questions and no note:", [r["topic"] for r in result if r["n_questions"] and not r["note_id"]])


def cmd_catalog(args):
    rows = scan_notes()
    os.makedirs(args.out, exist_ok=True)
    for r in rows:
        r["note_id"] = stable_note_id(r["path"])
    out = os.path.join(args.out, "note_catalog.json")
    json.dump(rows, open(out, "w", encoding="utf-8"), ensure_ascii=False)
    print("notes scanned:", len(rows), "->", out)
    by = {}
    for r in rows:
        by.setdefault(r["system_folder"], 0)
        by[r["system_folder"]] += 1
    for k in sorted(by):
        print(f"  {k:<44}{by[k]}")



# ---------------------------------------------------------------------------
# SQL generation (data for the tables in TEST/MIGRATION-NOTE-QUESTION-MAPPING.sql)
# ---------------------------------------------------------------------------
def q(v):
    """SQL literal for a python value."""
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    return "'" + str(v).replace("'", "''") + "'"


def system_name_for(note, folder_to_subject):
    return folder_to_subject.get(note["system_folder"], note["system_folder"])


def folder_subject_map():
    out = {}
    for subj, folders in SUBJECT_FOLDERS.items():
        for f in folders:
            out.setdefault(f, subj)
    return out


def run_sql_file(path):
    p = subprocess.run(["supabase", "db", "query", "--linked", "--agent=yes", "-o", "json", "-f", path],
                       cwd=ROOT, capture_output=True, text=True)
    if p.returncode:
        raise SystemExit("apply failed: " + (p.stderr or p.stdout)[-600:])
    return p.stdout


def cmd_sql_catalog(args):
    """note_catalog rows + test_topics.note_id (only exact / portal_alias / manual_review matches)."""
    cat = json.load(open(os.path.join(args.out, "note_catalog.json"), encoding="utf-8"))
    tmap = json.load(open(os.path.join(args.out, "topic_note_map.json"), encoding="utf-8"))
    f2s = folder_subject_map()
    by_path = {c["path"]: c for c in cat}
    lines = ["BEGIN;"]
    for c in cat:
        parent = None
        if c["is_subnote"]:
            # EKG HTML/<rhythm>.html belongs to the parent EKG note of the same system
            parent_path = "Notes/%s/EKG.html" % c["system_folder"] if "EKG HTML" in c["path"] else None
            parent = by_path[parent_path]["note_id"] if parent_path in by_path else None
        lines.append(
            "INSERT INTO public.note_catalog (note_id, system_name, title, subtitle, path, parent_note_id, content_sha256, headings) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s,%s::jsonb) ON CONFLICT (note_id) DO UPDATE SET "
            "system_name=EXCLUDED.system_name, title=EXCLUDED.title, subtitle=EXCLUDED.subtitle, path=EXCLUDED.path, "
            "parent_note_id=EXCLUDED.parent_note_id, content_sha256=EXCLUDED.content_sha256, headings=EXCLUDED.headings;"
            % (q(c["note_id"]), q(system_name_for(c, f2s)), q(c["title"]), q(c["subtitle"] or None), q(c["path"]),
               q(parent), q(c["sha256"]), q(json.dumps(c["headings"], ensure_ascii=False))))
    trusted = {"exact_title", "portal_alias", "manual_review"}
    n = 0
    for t in tmap:
        if t["method"] in trusted and t["note_id"]:
            lines.append("UPDATE public.test_topics SET note_id=%s WHERE id=%s;" % (q(t["note_id"]), q(t["topic_id"])))
            n += 1
    lines.append("COMMIT;")
    path = os.path.join(args.out, "populate_catalog.sql")
    open(path, "w", encoding="utf-8").write("\n".join(lines) + "\n")
    print("catalog rows:", len(cat), " topic links:", n, "->", path)
    if args.apply:
        run_sql_file(path)
        print("applied.")



def link_level(verdict):
    return {"supported": "direct", "partial": "partial", "unsupported": "unmatched"}.get(verdict, "unverified")


def cmd_sql_links(args):
    """question_note_links (+ review flags). Writes ONLY to the new tables; never edits test_questions."""
    cat = {c["note_id"]: c for c in json.load(open(os.path.join(args.out, "note_catalog.json"), encoding="utf-8"))}
    sup = json.load(open(os.path.join(args.out, "question_support.json"), encoding="utf-8"))
    qs = {r["id"]: r for r in json.load(open(args.questions, encoding="utf-8"))}
    tmap = {t["topic_id"]: t for t in json.load(open(os.path.join(args.out, "topic_note_map.json"), encoding="utf-8"))}
    idx = {}
    lines = ["BEGIN;"]
    stats = {"links": 0, "review": 0}
    for r in sup:
        if not r["note_id"]:
            continue
        note = cat[r["note_id"]]
        ix = idx.setdefault(r["note_id"], NoteIndex(note))
        # best supporting section = the section of the weakest-supported correct option
        correct = [o for o in r["options"] if o["correct"]]
        worst = min(correct, key=lambda o: o["best"]) if correct else None
        sec = anchor = None
        if worst:
            sc = ix.score(worst["text"])
            sec = sc["section"]
            anchor = (sc["block"].split(" | ")[0] or None)
        score = round(min((o["best"] for o in correct), default=0.0), 2)
        lines.append(
            "INSERT INTO public.question_note_links (question_id, note_id, role, section_heading, anchor_text, support_level, "
            "support_score, note_sha256, verified_by, verified_at) VALUES (%s,%s,'primary',%s,%s,%s,%s,%s,'auto-lexical-v2',now()) "
            "ON CONFLICT (question_id, note_id) DO UPDATE SET role='primary', section_heading=EXCLUDED.section_heading, "
            "anchor_text=EXCLUDED.anchor_text, support_level=EXCLUDED.support_level, support_score=EXCLUDED.support_score, "
            "note_sha256=EXCLUDED.note_sha256, verified_at=now();"
            % (r["question_id"], q(r["note_id"]), q(sec), q(anchor[:160] if anchor else None),
               q(link_level(r["verdict"])), score, q(note["sha256"])))
        stats["links"] += 1
        issues = []
        if r["verdict"] == "unsupported":
            issues.append("possible_note_gap")
        if "distractor_matches_note" in r["flags"]:
            issues.append("distractor_may_be_true")
        status = "needs_admin_review" if issues else "auto_checked"
        lines.append(
            "INSERT INTO public.question_review (question_id, status, issues, reviewed_by, reviewed_at) VALUES (%s,%s,%s::text[],'auto-lexical-v2',now()) "
            "ON CONFLICT (question_id) DO UPDATE SET status=CASE WHEN public.question_review.status IN ('admin_approved','retired_duplicate') "
            "THEN public.question_review.status ELSE EXCLUDED.status END, issues=EXCLUDED.issues, reviewed_at=now();"
            % (r["question_id"], q(status), q("{" + ",".join(issues) + "}")))
        stats["review"] += 1
    body = lines[1:]
    path = os.path.join(args.out, "populate_links.sql")
    open(path, "w", encoding="utf-8").write("BEGIN;\n" + "\n".join(body) + "\nCOMMIT;\n")
    print(stats, "->", path)
    if args.apply:
        # 2 statements per question; ~150 questions per transaction keeps each request small.
        # Idempotent (ON CONFLICT), so a failed chunk can simply be re-run.
        size = 300
        for n, i in enumerate(range(0, len(body), size), 1):
            chunk = os.path.join(args.out, "_links_chunk.sql")
            open(chunk, "w", encoding="utf-8").write("BEGIN;\n" + "\n".join(body[i:i + size]) + "\nCOMMIT;\n")
            run_sql_file(chunk)
            print("  applied chunk", n)
        print("applied.")



# ---------------------------------------------------------------------------
# Question-data fixes (each edit is logged to question_revisions; nothing is deleted)
# ---------------------------------------------------------------------------
FILLER_RE = re.compile(r"^This (?:pattern|finding|profile|presentation|picture|description|statement|option) is more consistent with ", re.I)
BROKEN_RATIONALE_RES = [
    re.compile(r"(?:,\s*)?\band\s*\.\s*$|,\s*and\s*\.", re.I),
    re.compile(r"\.\s+\.(?:\s|$)"),
    re.compile(r"\bIt (?:\d|<|>|AV|SA|pathway|Patient|standard|Not|Ventricular|Atrial)", re.I),
    re.compile(r",\s*\.\s*$"),
]
# Distractors a student could reasonably defend once the "in this note" qualifier is gone.
# Found by reading all 1,159 unique non-EKG distractors; edit this list only after clinical review.
AMBIGUOUS_DISTRACTORS = [
    "S3 is normal adult athletic finding.",            # S3 can be normal in young athletes/children
    "S4 is linked to normal youthful physiology.",
]


def cmd_sql_fixes(args):
    rows = json.load(open(args.questions, encoding="utf-8"))
    by_id = {r["id"]: r for r in rows}
    dups = json.load(open(os.path.join(args.out, "duplicates.json"), encoding="utf-8"))["keep_retire"]
    lines = ["BEGIN;"]
    stats = {"retired": 0, "opt_edits": 0, "q_edited": 0, "flag_broken": 0, "flag_filler": 0, "flag_ambiguous": 0}

    def rationale_quality(r):  # fewer visible defects wins
        t = r["rationale"] or ""
        return -sum(bool(rx.search(t)) for rx in BROKEN_RATIONALE_RES)

    retired = set()
    for d in dups:
        group = [by_id[d["keep"]]] + [by_id[i] for i in d["retire"]]
        keep = max(group, key=lambda r: (rationale_quality(r), -r["id"]))  # better text, then lowest id
        for r in group:
            if r["id"] == keep["id"]:
                continue
            retired.add(r["id"])
            lines.append("UPDATE public.test_questions SET is_active=false WHERE id=%d AND is_active=true;" % r["id"])
            lines.append(
                "INSERT INTO public.question_revisions (question_id, field, old_value, new_value, reason, changed_by) "
                "VALUES (%d,'is_active','true'::jsonb,'false'::jsonb,%s,'build_note_question_map.py');"
                % (r["id"], q("exact duplicate of question %d (same topic, stem, options, key)" % keep["id"])))
            lines.append(
                "INSERT INTO public.question_review (question_id, status, issues, duplicate_of, reviewed_by, reviewed_at) "
                "VALUES (%d,'retired_duplicate','{exact_duplicate}'::text[],%d,'build_note_question_map.py',now()) "
                "ON CONFLICT (question_id) DO UPDATE SET status='retired_duplicate', issues=EXCLUDED.issues, "
                "duplicate_of=EXCLUDED.duplicate_of, reviewed_at=now();" % (r["id"], keep["id"]))
            stats["retired"] += 1

    for r in rows:
        if r["id"] in retired:
            continue
        key = set(json.loads(r["correct_answer"]))
        new_opts, changed = [], False
        for o in r["options"]:
            t = o["text"]
            if QUALIFIER_RE.search(t):
                nt = strip_qualifier(t)
                if nt != t:
                    changed = True
                    stats["opt_edits"] += 1
                o = dict(o, text=nt)
            new_opts.append(o)
        if changed:
            lines.append("UPDATE public.test_questions SET options=%s::jsonb WHERE id=%d;"
                         % (q(json.dumps(new_opts, ensure_ascii=False)), r["id"]))
            lines.append(
                "INSERT INTO public.question_revisions (question_id, field, old_value, new_value, reason, changed_by) "
                "VALUES (%d,'options',%s::jsonb,%s::jsonb,%s,'build_note_question_map.py');"
                % (r["id"], q(json.dumps(r["options"], ensure_ascii=False)), q(json.dumps(new_opts, ensure_ascii=False)),
                   q("removed trailing 'in this note' qualifier (answer-giveaway: 55% of wrong options vs 6% of correct)")))
            stats["q_edited"] += 1
        # review flags (admin attention); never edits clinical text
        issues = []
        if any(rx.search(r["rationale"] or "") for rx in BROKEN_RATIONALE_RES):
            issues.append("broken_rationale"); stats["flag_broken"] += 1
        if any(FILLER_RE.match(re.sub(r"\s+", " ", o["text"]).strip()) for o in r["options"]):
            issues.append("filler_distractor"); stats["flag_filler"] += 1
        if any(strip_qualifier(o["text"]).strip() in AMBIGUOUS_DISTRACTORS and o["id"] not in key for o in r["options"]):
            issues.append("distractor_arguably_true"); stats["flag_ambiguous"] += 1
        if issues:
            lines.append(
                "UPDATE public.question_review SET status='needs_admin_review', "
                "issues=(SELECT array_agg(DISTINCT x) FROM unnest(public.question_review.issues || %s::text[]) AS x) WHERE question_id=%d;"
                % (q("{" + ",".join(issues) + "}"), r["id"]))
    lines.append("COMMIT;")
    body = lines[1:-1]
    path = os.path.join(args.out, "apply_fixes.sql")
    open(path, "w", encoding="utf-8").write("BEGIN;\n" + "\n".join(body) + "\nCOMMIT;\n")
    print(stats, "->", path, "(%d statements)" % len(body))
    if args.apply:
        # atomic per question group; each chunk is its own transaction and is safe to re-run only once
        # (revision rows are not idempotent), so chunks are cut at statement boundaries.
        size = 400
        for n, i in enumerate(range(0, len(body), size), 1):
            chunk = os.path.join(args.out, "_fix_chunk.sql")
            open(chunk, "w", encoding="utf-8").write("BEGIN;\n" + "\n".join(body[i:i + size]) + "\nCOMMIT;\n")
            run_sql_file(chunk)
            print("  applied chunk", n)
        print("applied.")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("catalog", help="scan Notes/ and write note_catalog.json")
    c.add_argument("--out", required=True)
    c.set_defaults(fn=cmd_catalog)
    t = sub.add_parser("topics", help="match test_topics to notes (needs catalog first)")
    t.add_argument("--out", required=True)
    t.set_defaults(fn=cmd_topics)
    sp = sub.add_parser("support", help="score question options against their note text")
    sp.add_argument("--out", required=True)
    sp.add_argument("--questions", required=True, help="JSON backup of test_questions")
    sp.set_defaults(fn=cmd_support)
    sc = sub.add_parser("sql-catalog", help="emit (and optionally apply) note_catalog + topic note_id SQL")
    sc.add_argument("--out", required=True)
    sc.add_argument("--apply", action="store_true")
    sc.set_defaults(fn=cmd_sql_catalog)
    sl = sub.add_parser("sql-links", help="emit (and optionally apply) question_note_links + review SQL")
    sl.add_argument("--out", required=True)
    sl.add_argument("--questions", required=True)
    sl.add_argument("--apply", action="store_true")
    sl.set_defaults(fn=cmd_sql_links)
    sf = sub.add_parser("sql-fixes", help="emit (and optionally apply) duplicate retirement + qualifier strip + review flags")
    sf.add_argument("--out", required=True)
    sf.add_argument("--questions", required=True)
    sf.add_argument("--apply", action="store_true")
    sf.set_defaults(fn=cmd_sql_fixes)
    args = ap.parse_args()
    args.fn(args)


if __name__ == "__main__":
    sys.exit(main())

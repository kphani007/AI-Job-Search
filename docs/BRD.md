# AI Job Search — Logic Summary (BRD)

A plain-language, bullet-point summary of the job-scout routine's current
logic, for quick reference. `docs/SCOUT.md` is the authoritative,
exhaustive spec the routine actually follows — this document is a
readable companion to it, not a replacement.

**Maintenance rule:** whenever a logic change or new requirement is made to
`docs/SCOUT.md` (a new source, a changed rule, a new widget, etc.), update
the relevant bullet(s) here in the **same PR**. If this document and
`docs/SCOUT.md` ever disagree, `docs/SCOUT.md` wins — treat that as a bug
in this document and fix it.

*Last updated: 2026-09-11.*

## 1. Objective

- Track new **Project/Delivery Management** and **Quality/QA** job postings
  — management **and individual-contributor** level
- Scope: **BFSI** (Banking, Financial Services & Insurance), **InsurTech**,
  **retirement/pension**, and **lending technology** (LMS/LOS)
- Geography: **global** (India + other countries)
- Cadence: at least once per weekday, append-only log

## 2. Role & Seniority Filter

- **PM/Delivery bucket**: Project Manager, Technical PM, Program Manager,
  Delivery Manager, PMO roles, plus IC-level (Project Coordinator, Delivery
  Lead, Implementation Specialist)
- **QA/Quality bucket**: QA Manager, Test Manager, plus IC-level (QA/Test
  Analyst, Tester, Quality Analyst)
- Seniority: **IC/Analyst through Senior Manager/Director** — VP+ and
  C-level explicitly excluded
- **Experience bias** (added 2026-09-11): searches favor ~14 years
  experience for PM/QA roles, ~7 years for SAP GTS roles — always
  *alongside* the sector filter below, never replacing it

## 3. Sector Filter (main list only)

- Must show a BFSI/InsurTech/lending/retirement signal in title, company,
  or summary
- Includes: insurers/InsurTech, BPO/delivery partners serving insurers
  (illumifin, WNS, eClerx), retirement/pension platforms, LMS/LOS lending
  tech, core banking/payments/fintech
- A generic "Project Manager" posting with **no** financial-services
  signal is out of scope, regardless of seniority match

## 4. Sources (main list)

- **Active**: LinkedIn, Naukri, Indeed, GitHub issues (manual leads)
- **Removed**: Jobaaj, Greenhouse, Wellfound, Glassdoor, Lever — all
  dropped after repeatedly surfacing dead/expired links (postings that go
  404 within days-to-weeks of appearing in search)
- `WebFetch` to any job-board domain is blocked by network policy —
  everything runs through `WebSearch` with `site:` filters instead

## 5. Inclusion Logic (main list) — "default to New unless proven stale"

- A posting goes to the **main list as `New`** by default
- It's only **excluded** if a date is actually found **and** that date
  confirms it's older than the recency window
- **No date shown at all** → still included as New (flipped from the
  original stricter rule, which required a *confirmed* date and caused
  almost everything to pile up as "Unverified")
- **Unverified Leads** bucket is reserved only for genuinely ambiguous
  cases (conflicting date signals) — rare, not a default parking spot

## 6. Recency Window

- **Main list**: 3 days
- **Freelancing / SAP GTS widgets**: 15 days, with a *stricter* rule — if
  the date can't be confirmed, skip it entirely (no fallback bucket)

## 7. Staleness Detection Techniques

- **LinkedIn**: job-ID magnitude — an ID well below the current "recent"
  range (drifts over time) signals stale
- **Naukri**: URL date encoding — the trailing numeric ID's first 6 digits
  are typically `DDMMYY` (validated against multiple postings, matched
  exactly)

## 8. Dedupe

- Same posting = matching normalized URL, **or** matching (Title, Company)
  pair
- Never re-logged once seen, even across sources (e.g., a LinkedIn posting
  and its mirror)

## 9. Two Separate Widgets (own rules, own sections)

- **Freelancing**: contract/freelance PM & QA gigs, **any sector** (no
  BFSI filter) — sourced from Upwork, Freelancer.com, Toptal,
  PeoplePerHour, Guru
- **SAP GTS**: any SAP Global Trade Services role, **any sector** (SAP GTS
  *is* the scope) — sourced from LinkedIn, Naukri, Indeed; explicit
  false-positive guard against unrelated "GTS" acronyms (HSBC, market-making
  firms)
- Both use the strict 15-day/confirmed-date-only rule, unlike the main
  list's lenient default

## 10. Dashboard (`docs/index.html`)

- 4 independent sections, each with its own stat tile: **All Tracked
  Jobs**, **Unverified Leads**, **Freelancing**, **SAP GTS**
- Stat counts are always computed from the underlying data arrays — never
  hand-typed, so they can't drift out of sync with the actual list

## 11. Failure Handling

- Every run logs a per-source result: `ok` / `blocked` / `skipped` — a
  blocked source is never silently reported as "0 new"
- A "0 new postings" commit message must show every source as `ok` or
  `skipped`

## Change log

- **2026-09-11**: Document created, summarizing the state of
  `docs/SCOUT.md` as of that date (source restriction to
  LinkedIn/Naukri/Indeed, default-to-New inclusion logic, SAP GTS widget,
  experience-level query bias).

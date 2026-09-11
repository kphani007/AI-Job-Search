# Job Scout — Operating Manual

This is the single source of truth for the daily BFSI/InsurTech/retirement
job digest routine. It replaces logic that previously existed only inside the
routine's prompt. A fresh agent with no prior context should be able to run a
complete, correct digest from this document alone.

Reverse-engineered from `seen-jobs.md` and `docs/index.html` history as of
2026-08-14, then revised 2026-08-14 per direct user feedback (recency window,
IC-level roles, sector/geography broadening, unverified-leads list, more
sources — see the diff that introduced this note for the before/after), then
revised again 2026-08-15 (Unverified Leads now shown on the dashboard in
their own section — see §11 step 1a), then revised again 2026-09-11 per
direct user feedback after ~4 weeks of runs showed the "must confirm an
absolute date" bar was almost never satisfiable — most board search
snippets never show one — so nearly everything (80 of 85 tracked postings)
was piling up in Unverified Leads instead of the main list. §5/§6 now
default a role/sector-matching posting to `New` unless a date is actually
found and confirms it's stale; Unverified Leads is kept only for genuinely
ambiguous cases. All 80 previously-Unverified rows were migrated into the
main table with `Status: New` in the same PR (their original "Date First
Seen" dates were preserved, not reset to the migration date). The same PR
also added §15, a SAP GTS widget (separate from the BFSI/InsurTech scope,
same pattern as the Freelancing widget). If reality and this document ever
disagree, update this document in the same PR — don't let the logic drift
back into an undocumented prompt.

**`docs/BRD.md`** is a short, plain-language bullet-point summary of this
document, for quick reference. Whenever a logic change or new requirement
is made here, update `docs/BRD.md`'s matching bullet(s) and its change log
in the **same PR** — this document stays the authoritative source, but the
two must not drift apart.

## 1. Goal

Track new Project/Delivery Management and Quality/QA job postings —
management **and individual-contributor** level — across BFSI (Banking,
Financial Services & Insurance), InsurTech, retirement/pension, and lending
technology (LMS/LOS), in India and other countries, for a Project Manager job
seeker. One run per day (or more — see §13), append-only.

## 2. Target roles and seniority

Include postings whose title matches either bucket:

- **PM / Delivery** (`category: "pm"`): Project Manager, Technical Project
  Manager, Program Manager, Delivery Manager, Senior Delivery Manager,
  Associate Project Manager, PMO roles, **plus IC-level: Project Coordinator,
  Project/PMO Analyst, Delivery Lead, Implementation Specialist/Manager**.
- **QA / Quality** (`category: "qa"`): QA Manager, Quality Assurance Manager,
  Quality Management Manager, Test Manager, **plus IC-level: QA
  Analyst/Engineer, Test Analyst/Engineer, Tester, Quality Analyst**.

Seniority: **IC/Analyst through Senior Manager / Director** (broadened
2026-08-14 — IC-level roles are now in scope, they were previously excluded).
Still exclude VP+ / C-level roles.

**Experience-level query bias (added 2026-09-11):** the user's own profile is
~14 years of PM/QA experience. When constructing search queries for §4's
sources, prefer including an explicit experience-level term/filter matching
this (e.g. `"10 to 15 years"`, `"12 to 17 years"`, `"13 to 18 years"` for
Naukri's phrasing, or an equivalent seniority cue for LinkedIn/Indeed) *in
addition to* — never instead of — the sector/domain terms from §3. A bare
keyword+experience query with no sector term (e.g. just `"quality manager"
14 years` with nothing BFSI-related) returns mostly off-sector noise, as
confirmed 2026-09-11: a live test of exactly that pattern surfaced construction,
manufacturing, and generic-consulting postings almost exclusively, all
excluded per §3's domain-signal requirement. Sector terms stay mandatory.

**Recency/jobAge query bias (added 2026-09-11):** in addition to the
experience-level bias above, prefer very fresh postings — mirroring
Naukri's own `jobAge` filter (`jobAge=1` = posted within the last day) and
its relevance/date sort, e.g. `naukri.com/sap-gts-consultant-jobs?k=sap
%20gts%20consultant&experience=7&jobAge=1`. `WebSearch` can't attach a job
board's own URL query parameters — it does a text search over indexed
content, not a live fetch of that exact URL — so approximate the same
intent by: (a) rotating in freshness-signaling terms in queries (`today`,
`just posted`, `new`), and (b) when a run turns up multiple qualifying
candidates, prioritize the ones confirmed ≤1-2 days old (via the
date-decoding/ID-magnitude techniques in §5/§15) when deciding what to
surface first. This does **not** change the recency *window* (§6: 3 days
main list / 15 days widgets) — it's about which candidates to search for
and prioritize, not which to admit.

If a title doesn't cleanly fit either category, still log it but pick the
closer of the two categories — the dashboard only has these two tabs plus
"All".

## 3. Target companies / sectors

No fixed company allowlist. Sector filter instead (broadened 2026-08-14 from
insurance/retirement-only to full BFSI):

- InsurTech vendors and platforms
- Life insurance, P&C (property & casualty) insurance, health insurance carriers
  and their delivery/BPM/BPO partners (e.g. illumifin, WNS, eClerx, Coforge —
  companies doing insurance-domain delivery work count even if not an insurer)
- Retirement / pension administration platforms
- Lending technology: LMS (Loan Management System) and LOS (Loan Origination
  System) platforms and vendors
- Banking and BFSI (Banking, Financial Services & Insurance) more broadly —
  core banking, payments, and fintech platforms count even without an
  explicit "insurance" or "retirement" label

A posting must reference one of the above domains in the title, company
description, or job summary. A generic "Project Manager" posting with no
BFSI/InsurTech/lending/retirement signal is still out of scope.

Geographic scope: **global — India and other countries** (broadened
2026-08-14 from India-only). Don't restrict to India; log strong matches from
any country.

### Target employer list (optional, user-maintained)

No fixed list yet. If you want tighter precision than generic board sweeps,
add specific employer names/domains here and the routine should add a
`site:<employer-domain>` career-page sweep for each as an extra source each
run. Empty for now.

## 4. Sources

WebFetch to job-board domains (linkedin.com, jobaaj.com, naukri.com,
indeed.com, greenhouse.io, etc.) is blocked by this environment's
network egress policy — confirmed for every job-board domain tested on
2026-08-14 (see §7). **Do not rely on WebFetch for job boards.** Use the
`WebSearch` tool with a `site:<domain>` filter instead — confirmed working
and returns individual job-posting URLs with title/company/location
snippets, which is enough to build a `seen-jobs.md` row without ever
fetching the page body.

| # | Source | Query method | Example query |
|---|---|---|---|
| 1 | LinkedIn Jobs (primary) | `WebSearch`, `site:linkedin.com/jobs` (global) and `site:in.linkedin.com/jobs` (India) | `site:linkedin.com/jobs project manager insurtech OR banking "10+ years"` |
| 2 | Naukri (secondary, India-focused) | `WebSearch`, `site:naukri.com` | `site:naukri.com delivery manager banking OR insurance "12 to 17 years"` |
| 3 | Indeed (secondary, global) | `WebSearch`, `site:indeed.com`, `site:in.indeed.com`, or other country domains (`site:uk.indeed.com`, etc.) as needed | `site:in.indeed.com project manager insurance senior` |
| 4 | Target employer career pages (optional, see §3) | `WebSearch`, `site:<employer-domain>/careers` | — |
| 5 | GitHub issues on this repo (manual leads) | `mcp__github__list_issues` (state OPEN) on `kphani007/AI-Job-Search` | — |

**Lever job boards (`jobs.lever.co`) — removed 2026-08-15.** Lever was a
source from 2026-08-14 to 2026-08-15. Dropped per direct user feedback:
`WebSearch` surfaced live-looking Lever URLs (e.g. the Inpay Fintech Project
Manager posting logged to Unverified Leads on 2026-08-15), but clicking
through returned a 404 ("The job posting you're looking for might have
closed, or it has been removed") within a day of being surfaced — Lever
listings expire/get pulled faster than `WebSearch`'s index catches up, so
the source can't be trusted to link to a live posting. Do not re-add
`site:jobs.lever.co` as a source unless a future run finds a reliable way to
confirm a Lever URL is still live before logging it (e.g. if `WebFetch` to
lever.co ever becomes unblocked, verify before logging rather than trusting
the search snippet).

**Jobaaj, Greenhouse, Wellfound, Glassdoor — removed 2026-09-11.** These four
were sources from 2026-08-14/15 through 2026-09-11. Dropped per direct user
feedback after clicking through to a Greenhouse-sourced posting (Affirm —
Quality Assurance Specialist II) and finding "The job you are looking for is
no longer open" — the same dead-link failure mode as the Lever removal above,
just on a longer fuse (weeks instead of a day). The user's explicit
instruction: only LinkedIn, Naukri, and Indeed are trustworthy/useful enough
to keep tracking — "ignore rest of the job postings. no use of having such
posts." All 72 previously-logged postings from these four sources were
retroactively removed from the main table in the same change (see
`seen-jobs.md`'s `## Removed — non-LinkedIn/Naukri/Indeed sources` section
for the full list). Do not re-add `site:jobaaj.com`, `site:*.greenhouse.io`,
`site:wellfound.com`, or `site:glassdoor.*` as sources for the main BFSI list
without new explicit user instruction. This does **not** apply to the
Freelancing widget (§14, its own separate source list — Upwork, Freelancer,
Toptal, PeoplePerHour, Guru — untouched) or the SAP GTS widget (§15,
untouched) — the user was explicit that this restriction is for the main
list only.

Run at least sources 1 and 5 every day; run the rest as supplementary
sweeps to widen coverage — you don't have to exhaust every source every
single run, but rotate through all of them across the week rather than
always skipping the same ones. Rotate/vary the exact query keywords
run-to-run (role terms × sector terms, including the new IC-level and
BFSI/lending terms from §2–3) rather than repeating one fixed query, to
surface postings a single fixed query would miss.

Source 5 exists because the user sometimes files a GitHub issue with a job
lead they found manually (e.g. issues #2, #5 in this repo's history). Treat
each open issue as a candidate lead: extract title/company/URL from the issue
body, log it with `Source: <original source> (GitHub issue lead)`, and note
in the run log that the issue was consumed. Leave the issue open unless you
have write access to close it as part of the digest (the routine does not
currently close issues automatically).

## 5. Inclusion / exclusion rules

A posting must match §2 (role bucket) and §3 (sector + geography) and not
already be logged per the dedupe key (§8). Given those three hold, it goes
into exactly one of three buckets:

1. **Main list, `Status: New`** — the default. Use this unless a date is
   actually found and that date confirms the posting is stale (bucket 3).
   No date shown at all, a relative date within the window ("2 days ago"),
   or a source that simply doesn't surface dates — all of these still go
   here as `New`, not held back. (Revised 2026-09-11 — see the note at the
   top of this document for why: requiring a *confirmed* date before
   logging as `New` meant almost nothing ever qualified, since most board
   search snippets don't show one.)
2. **Excluded, not logged** — a date *was* found and it confirms the
   posting is older than the recency window (§6). Also exclude regardless
   of date: roles that don't match either bucket in §2, even loosely, and
   postings with no BFSI/InsurTech/lending/retirement domain signal per §3.
3. **Unverified Leads list** (§9) — reserved for genuinely ambiguous cases
   only, e.g. conflicting date signals (a mirror site's indexed date looks
   fresh but the canonical listing you can cross-check suggests otherwise),
   or a case where you have a specific, documented reason to distrust an
   otherwise-qualifying match. This should be rare — don't use it as a
   default parking spot the way postings used to land here just for lacking
   a date.

**Known false-positive pattern:** job-board aggregators (Jobaaj in
particular) can mirror a LinkedIn posting and show a *found* date that is
much more recent than the *actual* posting date. The Allianz Technology
"Manager - Quality Management" posting was logged 2026-08-11 via Jobaaj, then
rejected after the user found the real post date was ~1 year old (see
`seen-jobs.md` row, "Rejected - stale posting", and commit `8862f62`). This
is why bucket 2 (exclude) requires an *actual confirmed* stale date, not a
guess — but it's also why a bare, unconfirmed relative date from a mirror
site isn't grounds to hold a posting back either; cross-check against the
canonical listing (e.g. the LinkedIn URL itself) when you can, and only
exclude if that confirms staleness.

## 6. Recency window

**3 days.** A posting is excluded only if its *confirmed* actual post date
(not the date a mirror site indexed it) is more than 3 days before the run
date — tightened 2026-08-14 from a previous 30-day default, per explicit
user instruction. Per §5 (revised 2026-09-11), the absence of a date is no
longer grounds to hold a posting out of the main list — it only matters
when a date is actually found, to check whether it falls outside this
window.

## 7. Source reachability (tested 2026-08-14)

Root cause of "0 new postings" runs and the "WebFetch egress blocked" commit
(`4043c72`, 2026-08-07): **direct `WebFetch` calls to every job-board domain
are blocked by this environment's network egress policy**, not source-specific.
Tested directly against this session:

| Domain | `WebFetch` | `WebSearch` (`site:` query) |
|---|---|---|
| linkedin.com / in.linkedin.com | **BLOCKED** (`EGRESS_BLOCKED`) | Works |
| jobaaj.com | **BLOCKED** | Works |
| naukri.com | **BLOCKED** | Works |
| indeed.com / in.indeed.com | **BLOCKED** | Works |
| job-boards.greenhouse.io | **BLOCKED** | Works |
| jobs.lever.co | **BLOCKED** | Works, but see the removal note in §4 — `WebSearch` results go stale/404 fast, dropped as a source 2026-08-15 |
| wellfound.com | not re-tested via WebFetch (assume blocked, same pattern) | Works |
| www.google.com, example.com, docs.anthropic.com | **BLOCKED** | n/a |
| raw.githubusercontent.com, GitHub API/MCP tools | Works | n/a |

The block is total (even `example.com` and Anthropic's own docs domain fail),
so this is a blanket network policy on the `WebFetch` tool in this
environment, not a per-site block — there is nothing to fix per-source.
`WebSearch` goes through a different backend and is unaffected. **§4's source
list is written assuming `WebSearch` is the fetch method; do not fall back to
`WebFetch` for job boards.** If a future environment does allow `WebFetch` to
a given board, it's fine to use it for higher-fidelity detail pages, but
`WebSearch` must remain the primary discovery method since it's the one
confirmed to work.

If `WebSearch` itself errors or returns nothing for a source on a given run,
that's a genuine per-run failure — record it in the run log (§9) rather than
silently treating it as "checked, zero results."

## 8. Dedupe key

A posting is a duplicate of an existing row **in either the main table or
the Unverified Leads table** (§9) if either matches:

1. **Primary:** the job URL, normalized (strip query strings/tracking
   params, e.g. `?utm_...`, trailing `?`). Two URLs that normalize to the
   same string are the same posting.
2. **Fallback:** `(Title, Company)` case-insensitively equal, when the same
   role is mirrored across sources under different URLs (e.g. a LinkedIn
   posting and its Jobaaj mirror) — log it once, preferring the original
   source (LinkedIn) over the mirror, and note the mirror in the row's
   Status if useful context.

Never re-add a row that already exists by either key, even with a new "Date
First Seen" — the date only reflects the first time this routine saw it. If
a lead in the Unverified Leads list later gets its date confirmed as within
the recency window, move it to the main table (add it there with
`Status: New`, remove the Unverified row) rather than leaving it duplicated
in both places.

## 9. `seen-jobs.md` entry format

Header (already present, do not duplicate):

```
# Seen Jobs Log
Format: | Date First Seen | Title | Company | Location | Source | URL | Status |
|---|---|---|---|---|---|---|
```

One row per posting, appended in date order:

```
| YYYY-MM-DD | <Title> | <Company> | <City, State or "India (city not stated)"> | <Source> | <Full URL> | <Status> |
```

- **Date First Seen**: today's run date, `YYYY-MM-DD`.
- **Source**: `LinkedIn`, `Jobaaj (LinkedIn-sourced)`, `Naukri`, `Indeed`, or
  `<Original Source> (GitHub issue lead)` for §4 source 10.
- **Status**: `New` for anything included per §5 bucket 1. If later found to be
  stale/invalid, don't delete the row — change Status to
  `Rejected - <reason>` (see the Allianz row for the exact pattern) so the
  history stays auditable.

### Unverified Leads (separate list, added 2026-08-14; scope narrowed 2026-09-11)

Postings matching §5 bucket 3 (genuinely ambiguous — see §5, this should be
rare) go in their own section, below the main table and above any Run log
sections — **not** mixed into the main table, and **not** counted toward
the "New" stats or the dashboard:

```
## Unverified Leads
Format: | Date Found | Title | Company | Location | Source | URL | Reason Unverified |
|---|---|---|---|---|---|---|
| YYYY-MM-DD | <Title> | <Company> | <Location> | <Source> | <Full URL> | e.g. "relative date only (2 weeks ago)" |
```

Same dedupe rule applies (§8) — check both tables before adding anywhere.
When a lead's ambiguity resolves toward in-window, move it to the main
table per §8; if it resolves toward stale, just leave it in Unverified Leads
(or delete the row — this list is a working review queue, not a permanent
audit log like the main table, so it's fine to prune stale/rejected-on-review
entries here rather than accumulating "Rejected" rows forever). As of
2026-09-11, don't route a posting here just because it lacks a date — per
§5 that now goes straight to the main table as `New`.

### Run log (required every run)

After the table, each run appends a dated run log block recording what was
actually checked — see §10 for the full spec. This is what makes a blocked
run distinguishable from a genuine zero-result day.

## 10. Failure handling and the Run log

**Never report "0 new postings" without also recording what was checked.** A
silent zero and a blocked fetch must be distinguishable at a glance.

After the dedupe/append step, append a `## Run log — YYYY-MM-DD` section to
the end of `seen-jobs.md` (below the table, below any prior run logs — newest
last, append-only, never rewrite prior run logs):

```
## Run log — YYYY-MM-DD

| Source | Result | Notes |
|---|---|---|
| LinkedIn (WebSearch) | ok | 3 candidates reviewed, 1 new |
| Jobaaj (WebSearch) | ok | 0 new (all already seen) |
| Naukri (WebSearch) | ok | 0 candidates matched filters |
| Indeed (WebSearch) | blocked | WebSearch returned no results / errored |
| GitHub issues | ok | 0 open leads |

New postings logged: 1. Rejected: 0.
```

`Result` must be one of:

- `ok` — the source was queried successfully, whether or not it produced a
  new posting. Say so in Notes either way (`N new` or `0 new — <why>`).
- `blocked` — the query itself failed (tool error, `EGRESS_BLOCKED`, timeout,
  auth wall). Never conflate this with `ok` + "0 new". Note the actual error.
- `skipped` — source intentionally not run this cycle (e.g. a supplementary
  source skipped to save time); say why.

A run that reports "0 new postings" in the commit message must have every
source row above marked `ok` or `skipped` — if any row is `blocked`, the
commit message must say so explicitly (e.g. `"0 new postings (LinkedIn
blocked — see run log)"`), matching the pattern already used in commit
`4043c72`.

## 11. Dashboard (`docs/index.html`) regeneration rules

`docs/index.html` is a single self-contained static file. As of 2026-09-11
it renders via **React, loaded from CDN with in-browser JSX transpilation
(Babel Standalone)** — no build step, no `package.json`, no CI. This was a
deliberate choice so the digest routine's regeneration procedure barely
changes: the data (`ALL_JOBS`, `TODAY_JOBS`, `UNVERIFIED_JOBS`,
`FREELANCE_JOBS`, `GTS_JOBS`, and now `LAST_UPDATED`) lives in its own
plain (non-JSX) `<script>` tag near the top of the file, exactly as
before — **only edit that block**, never the `<script type="text/babel">`
block below it (that's the React app itself; it reads the data arrays as
globals and shouldn't need to change for a routine run). On every run:

1. Rebuild the `ALL_JOBS` JS array from every `seen-jobs.md` row whose Status
   is `New` **in the main table only** (exclude `Rejected - *` rows and
   exclude the Unverified Leads table — those feed the separate
   `UNVERIFIED_JOBS` array in step 1a instead). Each entry:
   `{"date": "<Date First Seen>", "title", "company", "location", "source",
   "url", "status": "New", "category": "pm"|"qa"}`. Category comes from §2 —
   recompute it from the title, don't hand-carry it from a previous stat.
1a. Rebuild the `UNVERIFIED_JOBS` JS array from every row in the Unverified
    Leads table (§9), in the same order they appear there. Each entry:
    `{"date": "<Date Found>", "title", "company", "location", "source",
    "url", "reason": "<Reason Unverified>", "category": "pm"|"qa"}`.
    Shown on the dashboard in its own "Unverified Leads" section (added
    2026-08-15 per user request) — visually distinct from `ALL_JOBS` (amber
    "Unverified" badge, left-border accent, reason text shown on the row)
    and counted in its own "Unverified leads" stat tile, separate from
    "Total jobs tracked" / "Added today" which stay scoped to `New`
    postings only. As of 2026-09-11 this table (and array) should normally
    be empty or near-empty — §5 bucket 3 is now reserved for rare, genuinely
    ambiguous cases, not a default parking spot — so don't be surprised if
    most runs regenerate this as `[]`. If a lead's ambiguity resolves toward
    in-window, it moves from `UNVERIFIED_JOBS` to `ALL_JOBS` on the next run
    the same way.
1b. Rebuild the `FREELANCE_JOBS` JS array from every row in the Freelancing
    Leads table (§14), in the same order they appear there. Each entry:
    `{"date": "<Date Found>", "title", "company", "location", "source",
    "url", "category": "pm"|"qa"}`. Shown on the dashboard in its own
    "Freelancing" section (added 2026-08-15 alongside step 1a) — teal
    "Freelance" badge and left-border accent, own "Freelance gigs" stat
    tile, independent of `ALL_JOBS`/`UNVERIFIED_JOBS` and their stats.
1c. Rebuild the `GTS_JOBS` JS array from every row in the SAP GTS Leads
    table (§15, added 2026-09-11), in the same order they appear there.
    Each entry: `{"date": "<Date Found>", "title", "company", "location",
    "source", "url", "category": "gts"}` — SAP GTS roles don't map to the
    PM/QA split, so `category` is always the literal string `"gts"` here
    (not recomputed from title like the other arrays). Shown on the
    dashboard in its own "SAP GTS" section — indigo "SAP GTS" badge and
    left-border accent, own "SAP GTS roles" stat tile, independent of the
    other three arrays and their stats.
2. Rebuild `TODAY_JOBS` as the subset of `ALL_JOBS` whose `date` equals
   today's run date.
3. Update the `LAST_UPDATED` string constant (in the same plain data
   `<script>` block, not the `.meta-row` markup — as of 2026-09-11 the React
   app reads this constant rather than hand-typed HTML) to the current run's
   date/time (IST, matching the existing format, e.g.
   `14 Aug 2026, 09:15 AM IST`).
4. **Do not hand-write the stat-tile numbers.** They must be computed by the
   page's own script from `ALL_JOBS.length` / `TODAY_JOBS.length` /
   `UNVERIFIED_JOBS.length` / `FREELANCE_JOBS.length` / `GTS_JOBS.length` so
   the displayed counts can never drift out of sync with the actual job
   list — that drift was the root cause of the "5 tracked but list empty"
   dashboard bug. If you're hand-editing the HTML instead of regenerating it
   wholesale, do not touch the React app's JSX or the stat-tile rendering.
5. **Result sets render newest-first everywhere** (added 2026-09-11) — the
   React app sorts every list (`ALL_JOBS`, `UNVERIFIED_JOBS`,
   `FREELANCE_JOBS`, `GTS_JOBS`, `TODAY_JOBS`) by `date` descending at
   render time. This is display-only: `seen-jobs.md`'s own tables stay
   append-only in chronological (ascending) order per §9/§14/§15 — don't
   reorder rows there, the sort happens purely in the browser.
6. **Section order** (changed 2026-09-11, per direct user request): the page
   now renders **Freelancing, then SAP GTS, then New Today, then All
   Tracked Jobs, then Unverified Leads** — Freelancing and SAP GTS moved
   above the main-list sections. If adding a new section in the future,
   don't silently reorder this list without being asked.
7. **SAP GTS nav pill** (added 2026-09-11): the tabs row has a 4th button,
   "SAP GTS", styled distinctly (indigo/gts-colored outline, not a filled
   "active" state like the other three). Unlike the All/PM/QA pills — which
   filter the "All Tracked Jobs" list by category — this pill does **not**
   filter anything; it smooth-scrolls the page to the SAP GTS section. SAP
   GTS jobs stay in their own separate `GTS_JOBS` array/section, never
   merged into `ALL_JOBS`'s pm/qa dataset.
8. Everything else in the file (styles, the general page structure) is
   static scaffolding — leave it as-is unless explicitly asked to change the
   UI. The search/tab filter controls (All/PM/QA) apply to `ALL_JOBS` only —
   the Unverified Leads, Freelancing, and SAP GTS sections are not wired to
   them (small, review-queue-sized lists; add filtering later only if any of
   them grows enough to need it).

## 12. When a source is unreachable

1. Record it as `blocked` in the run log (§10) with the actual error/reason.
2. Try the fallback methods in order before giving up on that source for the
   run: (a) `WebSearch` with a `site:` filter if the direct method failed,
   (b) a broader `WebSearch` query without the `site:` filter, (c) skip and
   note it.
3. Never let one blocked source suppress the whole run — continue with the
   remaining sources and still commit whatever was found (even if that's
   nothing), with the run log reflecting exactly what happened.
4. If **every** source is blocked, still commit: update the run log (all
   rows `blocked`), refresh the dashboard timestamp, and use a commit message
   like `"Job digest YYYY-MM-DD: 0 new postings (all sources blocked — see
   run log)"` — do not silently report a clean zero.

## 13. Ideas for broadening coverage further (proposed, not yet adopted)

Suggestions surfaced 2026-08-14, not implemented until the user picks them:

- **Run more than once a day.** The 3-day recency window (§6) is strict
  relative to a once-a-day, weekday-only schedule — a posting found on
  Friday morning could already be borderline by Monday. Running twice a day
  (e.g. 9am and 5pm IST) or daily including weekends would catch more inside
  the window without changing the window itself.
- **Query rotation matrix.** Instead of ad hoc queries, systematically cycle
  through combinations of {role terms from §2} × {sector terms from §3} ×
  {optional country} across runs, so coverage compounds over the week rather
  than each run re-covering the same ground.
- **Build out the target employer list (§3).** A short list of specific
  BFSI/InsurTech/lending companies you care about, searched via
  `site:<employer>/careers`, would be far more precise than generic board
  sweeps and cheap to run alongside them.
- **Country-specific board variants.** Indeed and LinkedIn have per-country
  domains (e.g. `uk.indeed.com`, `ca.indeed.com`); worth adding on a rotation
  if non-India geographies matter as much as India.
- **Naukri sibling sites** (Foundit/Monster India, Shine, Instahyre) and
  **Glassdoor** — Glassdoor already showed up organically in a test search
  (§4 source 7); the others haven't been spot-checked yet but are likely
  reachable the same way (`WebSearch` + `site:`).

None of these are required — they're options if the current source/role/
sector breadth still isn't surfacing enough. Update this section (or delete
it) once a decision is made.

## 14. Freelancing widget (added 2026-08-15)

Separate from the BFSI/InsurTech/lending/retirement scope in §1–§3. This
widget tracks contract/freelance **Testing (QA)** and **Project/Program/
Delivery Management** gigs, **any domain or sector** — sourced from
freelance marketplaces rather than the standard job boards in §4.

### Role scope

Same two title buckets as §2 (PM/Delivery, QA/Quality — including the
IC-level titles), same seniority range (IC/Analyst through Senior
Manager/Director). **No domain/sector filter applies here** — a freelance
PM or QA gig in retail, media, travel, or any other unrelated industry is
in scope for this widget even though it would be out of scope for the main
list and Unverified Leads (§2–§3 still gate those).

### Contract-type signal required

The posting must show a freelance/contract/gig signal: either sourced from
a freelance-specific marketplace (see Sources below), or — if surfaced from
a general board — the listing itself says "contract", "freelance",
"remote — contract", or similar. A permanent/full-time role does not
qualify for this widget even if found on a freelance-adjacent site; if it
also matches §2–§3, log it to the main list/Unverified Leads instead, not
here.

### Sources

Use `WebSearch` with `site:` filters, same `WebFetch`-blocked caveat as
§4/§7. **Do not use `jobs.lever.co`** for this widget either — see the
Lever removal note in §4 (dead/expired listings within days of being
surfaced by `WebSearch`), which applies regardless of which list a Lever
posting would be destined for.

| # | Source | Example query |
|---|---|---|
| 1 | Upwork | `site:upwork.com project manager OR QA testing freelance` |
| 2 | Freelancer.com | `site:freelancer.com "project manager" OR "QA tester" job` |
| 3 | Toptal | `site:toptal.com project manager OR QA freelance` |
| 4 | PeoplePerHour | `site:peopleperhour.com project manager OR QA tester` |
| 5 | Guru | `site:guru.com project manager OR QA tester freelance` |

Rotate/vary keywords the same way as §4. Record these sources in the same
run log table as the main sources (§10), using the source names above.

### Recency window

**15 days** — looser than the main list's 3-day window (§6), tighter than
the original 30-day default. Note this widget deliberately did **not**
follow the 2026-09-11 default-to-New change made to the main list (§5) —
keep this widget simple: **if the post date can't be confirmed within 15
days, skip it** — there is no separate "unverified freelancing" bucket to
fall back to. (§15's SAP GTS widget uses this same stricter rule, by
explicit user choice, rather than the main list's default-to-New rule.)

### `seen-jobs.md` entry format

Its own table, positioned below the Unverified Leads table (§9), above the
Run log sections:

```
## Freelancing Leads
Format: | Date Found | Title | Client/Company | Location | Source | URL |
|---|---|---|---|---|---|
| YYYY-MM-DD | <Title> | <Client/Company> | <Location> | <Source> | <Full URL> |
```

Same dedupe rule (§8) applies within this table. Also check the main table
and Unverified Leads before logging here — if the exact same URL or
(Title, Company) pair already exists in either of those, don't double-log
it into Freelancing Leads too.

### Dashboard

Per §11, rebuild a `FREELANCE_JOBS` JS array from every row in this table:
`{"date", "title", "company", "location", "source", "url", "category":
"pm"|"qa"}` (category recomputed from title, same as `ALL_JOBS`). Shown in
its own "Freelancing" dashboard section — distinct badge/accent color from
both `ALL_JOBS` and `UNVERIFIED_JOBS` — with its own stat tile, independent
of the other two arrays and their stats.

## 15. SAP GTS widget (added 2026-09-11)

Separate from the BFSI/InsurTech/lending/retirement scope in §1–§3, and
separate from the Freelancing widget (§14) — this one has nothing to do with
contract work. It tracks **any SAP GTS (Global Trade Services) role**,
any employer, any industry — SAP GTS is itself the scope, the way BFSI is
the scope for the main list.

### Role scope

Any job whose title references SAP GTS specifically — "SAP GTS Consultant",
"SAP GTS Techno-Functional Consultant", "SAP Global Trade Services
Analyst/Manager/Specialist", "SAP GTS Project Manager", "GTS Compliance
Consultant (SAP)", etc. Seniority: IC/Analyst through Director, same range
as §2 (exclude VP+/C-level). No PM-vs-QA split here — SAP GTS work spans
functional, technical, and project roles indiscriminately, so there's no
`pm`/`qa` categorization to make; see the Dashboard section below.

**Experience-level query bias (added 2026-09-11):** the user's SAP GTS
experience is ~7 years — prefer queries that include an explicit
experience-level term matching this (e.g. `"5 to 10 years"`, `"6 to 11
years"`, `"7 to 12 years"` for Naukri's phrasing) alongside the `"SAP GTS"`
term itself, same rationale as §2's experience-level bias for the main list.

**Recency/jobAge query bias (added 2026-09-11):** same rationale as §2's —
mirror Naukri's `jobAge=1` filter concept (e.g. `naukri.com/sap-gts-
consultant-jobs?k=sap%20gts%20consultant&experience=7&jobAge=1`) by
rotating freshness terms into queries and prioritizing ≤1-2-day-old
confirmed candidates when several qualify in one run. Doesn't change the
15-day window, only search/prioritization emphasis.

**Watch for false positives on the bare acronym "GTS"** — it collides with
unrelated things (HSBC's "Global Trade Solutions" business line, "Global
Trading Systems" the market-making firm, generic "Global Trade Services"
teams with no SAP product involved). Only log a posting if the title or
description makes the **SAP** product connection explicit — a plain
"Global Trade Services Analyst" with no mention of SAP, GTS module
configuration, customs/compliance system work tied to SAP ERP/S4, etc. is
not in scope.

### Sources

**Run all three main sources every time this widget is checked — not just
LinkedIn.** (Fixed 2026-09-11 after the user manually found a qualifying
Naukri posting that a LinkedIn-only sweep had missed entirely; see
`seen-jobs.md`'s dated addendum for the full incident.) Use `WebSearch` with
`site:` filters, same `WebFetch`-blocked caveat as §4/§7:

- `site:linkedin.com/jobs "SAP GTS"` and `site:in.linkedin.com/jobs "SAP GTS"`
- `site:naukri.com "SAP GTS" "7 to 12 years"` (rotate the experience phrase
  per the bias noted in Role scope above — `"5 to 10 years"`, `"6 to 11
  years"`, etc.)
- `site:indeed.com "SAP GTS"` / `site:in.indeed.com "SAP GTS"`

Also opportunistically check any of the §4/§14 sources if SAP GTS postings
turn up there too. Don't use `jobs.lever.co` (see the removal note in §4),
and don't use `jobaaj.com`/`greenhouse.io`/`wellfound.com`/`glassdoor.*`
(removed 2026-09-11, see §4) even for this widget.

**Two ways to confirm a post date, beyond an explicit date in the snippet:**
1. **Naukri URL date encoding** — on `naukri.com/job-listings-...-NNNNNN` URLs
   (not the shorter `recruiter-job-listings-...` variant, which uses a
   different, unconfirmed ID scheme), the trailing numeric ID's first 6
   digits are typically a `DDMMYY`-encoded post date. Validated 2026-09-11
   against 6 postings where `WebSearch` also surfaced an explicit "Posted
   <date>" narrative summary — 6/6 matched (one off by a day, likely a
   display/index rounding quirk). Trust this when present; still skip if the
   ID doesn't look like this pattern.
2. **LinkedIn job-ID magnitude** — the existing heuristic (see the 2026-08-15
   run log entries): an ID well below the current run's confirmed-recent
   range (roughly 4.44–4.49B as of early September 2026, drifts upward over
   time) means stale: treat as a confirmed exclusion, not merely unverified.

### Recency window

**15 days**, with the same strict rule as §14: **if the post date can't be
confirmed within 15 days, skip it** — no separate "unverified GTS" bucket.
This is a deliberate, explicit choice (not an oversight) to keep this
widget consistent with Freelancing rather than adopting the main list's
2026-09-11 default-to-New change — expect this widget to come up empty on
many runs, the same way Freelancing did for its first ~20 runs, since SAP
GTS postings are a narrow niche and search snippets rarely carry a
confirmable date. That's an acceptable, known trade-off of the choice, not
a bug to fix.

### `seen-jobs.md` entry format

Its own table, positioned below the Freelancing Leads table (§14), above
the Run log sections:

```
## SAP GTS Leads
Format: | Date Found | Title | Company | Location | Source | URL |
|---|---|---|---|---|---|
| YYYY-MM-DD | <Title> | <Company> | <Location> | <Source> | <Full URL> |
```

Same dedupe rule (§8) applies within this table. Also check the main table,
Unverified Leads, and Freelancing Leads before logging here — if the exact
same URL or (Title, Company) pair already exists in any of those, don't
double-log it into SAP GTS Leads too (in practice this is unlikely to
matter, since SAP GTS roles rarely also carry a BFSI/InsurTech signal, but
check anyway).

### Dashboard

Per §11 step 1c, rebuild a `GTS_JOBS` JS array from every row in this
table: `{"date", "title", "company", "location", "source", "url",
"category": "gts"}` — category is always the literal `"gts"`, not
recomputed from title. Shown in its own "SAP GTS" dashboard section —
distinct badge/accent color from `ALL_JOBS`, `UNVERIFIED_JOBS`, and
`FREELANCE_JOBS` — with its own stat tile, independent of the other three
arrays and their stats.

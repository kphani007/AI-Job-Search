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
their own section — see §11 step 1a). If reality and this document ever
disagree, update this document in the same PR — don't let the logic drift
back into an undocumented prompt.

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
| 1 | LinkedIn Jobs (primary) | `WebSearch`, `site:linkedin.com/jobs` (global) and `site:in.linkedin.com/jobs` (India) | `site:linkedin.com/jobs project manager insurtech OR banking` |
| 2 | Jobaaj (secondary / LinkedIn mirror, India-focused) | `WebSearch`, `site:jobaaj.com` | `site:jobaaj.com quality assurance manager insurance India` |
| 3 | Naukri (secondary, India-focused) | `WebSearch`, `site:naukri.com` | `site:naukri.com delivery manager banking OR insurance` |
| 4 | Indeed (secondary, global) | `WebSearch`, `site:indeed.com`, `site:in.indeed.com`, or other country domains (`site:uk.indeed.com`, etc.) as needed | `site:in.indeed.com project manager insurance` |
| 5 | Greenhouse job boards (secondary, global — added 2026-08-14) | `WebSearch`, `site:boards.greenhouse.io` or `site:job-boards.greenhouse.io` | `site:boards.greenhouse.io project manager insurtech OR lending` |
| 6 | Wellfound/AngelList (secondary, startup-focused — added 2026-08-14) | `WebSearch`, `site:wellfound.com` | `site:wellfound.com project manager insurtech OR fintech` |
| 7 | Glassdoor (opportunistic — added 2026-08-14) | `WebSearch`, `site:glassdoor.com` or `site:glassdoor.co.in` | `site:glassdoor.co.in project manager banking` |
| 8 | Target employer career pages (optional, see §3) | `WebSearch`, `site:<employer-domain>/careers` | — |
| 9 | GitHub issues on this repo (manual leads) | `mcp__github__list_issues` (state OPEN) on `kphani007/AI-Job-Search` | — |

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

Run at least sources 1 and 9 every day; run the rest as supplementary
sweeps to widen coverage — you don't have to exhaust every source every
single run, but rotate through all of them across the week rather than
always skipping the same ones. Rotate/vary the exact query keywords
run-to-run (role terms × sector terms, including the new IC-level and
BFSI/lending terms from §2–3) rather than repeating one fixed query, to
surface postings a single fixed query would miss.

Sources 5–6 were spot-checked on 2026-08-14 and confirmed to return
individual, relevant postings via `WebSearch` (e.g. Greenhouse boards for
Kin Insurance, LendingTree, Pie Insurance) — see §7 for the reachability
table.

Source 9 exists because the user sometimes files a GitHub issue with a job
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

1. **Main list, `Status: New`** — post date is *confirmed* within the
   recency window (§6, 3 days).
2. **Unverified Leads list** (§9) — role/sector match confirmed, but the
   post date could not be confirmed as within the recency window (only a
   relative date like "2 weeks ago", no date shown at all, or a mirror site
   whose indexed date is untrustworthy). Logged separately, not counted as
   "New" in the dashboard/stats, for manual review.
3. **Excluded, not logged** — post date is *confirmed* older than the
   recency window. Genuinely stale, no ambiguity, nothing to review.

Also exclude and do not log (regardless of date):

- Roles that don't match either bucket in §2, even loosely.
- Postings with no BFSI/InsurTech/lending/retirement domain signal per §3.

**Known false-positive pattern:** job-board aggregators (Jobaaj in
particular) can mirror a LinkedIn posting and show a *found* date that is
much more recent than the *actual* posting date. The Allianz Technology
"Manager - Quality Management" posting was logged 2026-08-11 via Jobaaj, then
rejected after the user found the real post date was ~1 year old (see
`seen-jobs.md` row, "Rejected - stale posting", and commit `8862f62`). This
is exactly the pattern bucket 2 above exists to catch now: when a source
shows a relative date without an absolute one, don't guess — put it in the
Unverified Leads list instead of the main New list. Cross-check against the
canonical listing (e.g. the LinkedIn URL itself) when you can; if that
confirms a date outside the window, treat it like bucket 3 (exclude/reject)
instead.

## 6. Recency window

**3 days.** A posting is in-window only if its *confirmed* actual post date
(not the date a mirror site indexed it) is no more than 3 days before the
run date — tightened 2026-08-14 from a previous 30-day default, per explicit
user instruction. This is deliberately strict: most generic board-search
snippets only show relative dates ("2 weeks ago") with no day-level
precision, so expect most candidates to land in the Unverified Leads list
(§9) rather than the main New list. That's intentional — precision on the
main list, breadth preserved in the unverified list rather than dropped
entirely. See §13 for a suggestion on running more than once/day given how
tight this window is.

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

### Unverified Leads (separate list, added 2026-08-14)

Postings matching §5 bucket 2 (role/sector match, unconfirmed date) go in
their own section, below the main table and above any Run log sections —
**not** mixed into the main table, and **not** counted toward the "New"
stats or the dashboard:

```
## Unverified Leads
Format: | Date Found | Title | Company | Location | Source | URL | Reason Unverified |
|---|---|---|---|---|---|---|
| YYYY-MM-DD | <Title> | <Company> | <Location> | <Source> | <Full URL> | e.g. "relative date only (2 weeks ago)" |
```

Same dedupe rule applies (§8) — check both tables before adding anywhere.
When a lead's date later gets confirmed as in-window, move it to the main
table per §8; if confirmed as stale, just leave it in Unverified Leads (or
delete the row — this list is a working review queue, not a permanent
audit log like the main table, so it's fine to prune stale/rejected-on-review
entries here rather than accumulating "Rejected" rows forever).

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

`docs/index.html` is a single self-contained static file. On every run:

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
    2026-08-15 per user request, after the user noticed the leads found on
    2026-08-15's run weren't visible anywhere on the site) — visually
    distinct from `ALL_JOBS` (amber "Unverified" badge, left-border accent,
    reason text shown on the row) and counted in its own "Unverified leads"
    stat tile, separate from "Total jobs tracked" / "Added today" which stay
    scoped to confirmed `New` postings only. If a lead is later moved from
    Unverified Leads to the main table per §8, it moves from
    `UNVERIFIED_JOBS` to `ALL_JOBS` on the next run the same way.
1b. Rebuild the `FREELANCE_JOBS` JS array from every row in the Freelancing
    Leads table (§14), in the same order they appear there. Each entry:
    `{"date": "<Date Found>", "title", "company", "location", "source",
    "url", "category": "pm"|"qa"}`. Shown on the dashboard in its own
    "Freelancing" section (added 2026-08-15 alongside step 1a) — teal
    "Freelance" badge and left-border accent, own "Freelance gigs" stat
    tile, independent of `ALL_JOBS`/`UNVERIFIED_JOBS` and their stats.
2. Rebuild `TODAY_JOBS` as the subset of `ALL_JOBS` whose `date` equals
   today's run date.
3. Update the `Last updated:` timestamp in the `.meta-row` to the current
   run's date/time (IST, matching the existing format, e.g.
   `14 Aug 2026, 09:15 AM IST`).
4. **Do not hand-write the stat-tile numbers.** They must be computed by the
   page's own script from `ALL_JOBS.length` / `TODAY_JOBS.length` /
   `UNVERIFIED_JOBS.length` / `FREELANCE_JOBS.length` so the displayed
   counts can never drift out of sync with the actual job list — that drift
   was the root cause of the "5 tracked but list empty" dashboard bug. If
   you're hand-editing the HTML instead of regenerating it wholesale, do not
   touch the stat tile markup at all.
5. Everything else in the file (styles, controls, filter/search JS) is
   static scaffolding — leave it as-is unless explicitly asked to change the
   UI. The search/tab filter controls apply to `ALL_JOBS` only — the
   Unverified Leads and Freelancing sections are not wired to them (small,
   review-queue-sized lists; add filtering later only if either grows enough
   to need it).

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
the original 30-day default. Same "confirmed vs. unconfirmed date" logic as
§5 applies for judgment calls, but keep this widget simple: **if the post
date can't be confirmed within 15 days, skip it** — there is no separate
"unverified freelancing" bucket to fall back to.

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

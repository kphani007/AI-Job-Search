# Job Scout — Operating Manual

This is the single source of truth for the daily BFSI/InsurTech/retirement
job digest routine. It replaces logic that previously existed only inside the
routine's prompt. A fresh agent with no prior context should be able to run a
complete, correct digest from this document alone.

Reverse-engineered from `seen-jobs.md` and `docs/index.html` history as of
2026-08-14, then revised 2026-08-14 per direct user feedback (recency window,
IC-level roles, sector/geography broadening, unverified-leads list, more
sources — see the diff that introduced this note for the before/after). If
reality and this document ever disagree, update this document in the same
PR — don't let the logic drift back into an undocumented prompt.

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
indeed.com, greenhouse.io, lever.co, etc.) is blocked by this environment's
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
| 6 | Lever job boards (secondary, global — added 2026-08-14) | `WebSearch`, `site:jobs.lever.co` | `site:jobs.lever.co project manager fintech OR insurtech` |
| 7 | Wellfound/AngelList (secondary, startup-focused — added 2026-08-14) | `WebSearch`, `site:wellfound.com` | `site:wellfound.com project manager insurtech OR fintech` |
| 8 | Glassdoor (opportunistic — added 2026-08-14) | `WebSearch`, `site:glassdoor.com` or `site:glassdoor.co.in` | `site:glassdoor.co.in project manager banking` |
| 9 | Target employer career pages (optional, see §3) | `WebSearch`, `site:<employer-domain>/careers` | — |
| 10 | GitHub issues on this repo (manual leads) | `mcp__github__list_issues` (state OPEN) on `kphani007/AI-Job-Search` | — |

Run at least sources 1 and 10 every day; run the rest as supplementary
sweeps to widen coverage — you don't have to exhaust every source every
single run, but rotate through all of them across the week rather than
always skipping the same ones. Rotate/vary the exact query keywords
run-to-run (role terms × sector terms, including the new IC-level and
BFSI/lending terms from §2–3) rather than repeating one fixed query, to
surface postings a single fixed query would miss.

Sources 5–7 were spot-checked on 2026-08-14 and confirmed to return
individual, relevant postings via `WebSearch` (e.g. Greenhouse boards for
Kin Insurance, LendingTree, Pie Insurance; Lever boards for fintech/insurtech
PM roles) — see §7 for the reachability table.

Source 10 exists because the user sometimes files a GitHub issue with a job
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
| job-boards.greenhouse.io, jobs.lever.co | **BLOCKED** | Works |
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
   exclude the entire Unverified Leads table — those are a manual-review
   queue, not shown on the dashboard, by design). Each entry:
   `{"date": "<Date First Seen>", "title", "company", "location", "source",
   "url", "status": "New", "category": "pm"|"qa"}`. Category comes from §2 —
   recompute it from the title, don't hand-carry it from a previous stat.
2. Rebuild `TODAY_JOBS` as the subset of `ALL_JOBS` whose `date` equals
   today's run date.
3. Update the `Last updated:` timestamp in the `.meta-row` to the current
   run's date/time (IST, matching the existing format, e.g.
   `14 Aug 2026, 09:15 AM IST`).
4. **Do not hand-write the stat-tile numbers.** They must be computed by the
   page's own script from `ALL_JOBS.length` / `TODAY_JOBS.length` (see the
   fix in this PR) so the displayed counts can never drift out of sync with
   the actual job list — that drift was the root cause of the "5 tracked but
   list empty" dashboard bug. If you're hand-editing the HTML instead of
   regenerating it wholesale, do not touch the stat tile markup at all.
5. Everything else in the file (styles, controls, filter/search JS) is
   static scaffolding — leave it as-is unless explicitly asked to change the
   UI.

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
  (§4 source 8); the others haven't been spot-checked yet but are likely
  reachable the same way (`WebSearch` + `site:`).

None of these are required — they're options if the current source/role/
sector breadth still isn't surfacing enough. Update this section (or delete
it) once a decision is made.

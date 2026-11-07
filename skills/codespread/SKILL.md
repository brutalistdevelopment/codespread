---
name: codespread
description: Find what makes a codebase expensive to change, from its git history - which files keep changing together across the directory tree, and where the work of a typical change spreads. Use when the user asks what makes change expensive or slow, where the coupling is, where to refactor or restructure, whether a folder or module boundary is in the right place, whether a refactoring paid off, or what a branch or the work in progress would do to the codebase before it merges. Works on git repositories in TypeScript, JavaScript, Python and Rust.
---

# CodeSpread

CodeSpread measures how far the work of a typical change spreads through a repository's directory tree, against
random placement: its Spread. It shows where that Spread sits, folder by folder. Its findings point at code;
turning them into a refactoring is your job, in the repository's own terms.

## 1. Find the tool

Use the `snapshot` and `pending_change` tools of the `codespread` MCP server when it is connected. Otherwise run
`command -v codespread`. If neither is there, stop and tell the user how to add it, and do not install it yourself:

- as an MCP server: `claude mcp add codespread -- docker run -i --rm -v "$PWD:/repo:ro" brutalistdevelopment/codespread`,
  or `claude mcp add codespread -- npx -y codespread mcp`;
- as a command: `npm install --global codespread` (Node 24 or later).

## 2. Take a Snapshot

A Snapshot is of the checkout as it is: the first-parent history of the checked-out commit, each commit one change,
and the uncommitted work as one more change, the newest. Only the last 1,080 days count. Commits on an unmerged branch
count one by one; say so if there are many. The page's first line gives the Spread with its standard error; the second
names the commit, says "with uncommitted work" when that counted, and how long the analysis took.

Call `snapshot` without a path, or run:

```bash
codespread <repository>                     # the page of the whole repository
codespread <repository> --path src/api      # the page of one folder or file
codespread <repository> --limit 20          # longer lists; 10 by default
```

Every call reads the history again: seconds on most repositories, longer on very large ones.

## 3. Read the page

The page of the repository, or of a folder or file with `--path`, has:

- **The summary**: the Spread contained in it and crossing its edge; on the repository's page, only its name.
- **Where changes split**: a folder and the two entries where co-changing files part ways (not on a file's page).
- **Pairs with the most Spread**: the files most often changed together across distance.
- **Partner areas**: where its crossing Spread goes, when it has any.

Read [INTERPRETING.md](INTERPRETING.md) for what they mean.

## 4. Judge how much the numbers say

Lead with the Spread and its standard error. Lower is better; for reference, two large, actively developed
applications measured in 2026: Zulip 0.31, Django 0.43. A wide error, or a history of only a few dozen commits touching
two or more source files, makes a thin sample: say so, and treat findings as leads. If it is not measurable, say why
(no recent change touches two source files, or all co-changing files sit in one folder) and stop.

## 5. Drill down and pick at most three findings

Start from the largest Splits, open the page of the folder each names, and follow its Splits and partner areas down to
the Pairs. Prefer a finding that explains several others, such as one Split behind many Pairs.

## 6. Look at the code behind each finding

Numbers say where; the code says why. For each finding, open the files and find what ties them: an import, a shared
concept, a duplicated rule.
`git log --format='%h %s' -- <file-a> <file-b>` shows the changes that touched them; read a few that touched both to
see what kind of work keeps crossing.

## 7. Report

For each finding: the evidence (figures, files, the page it came from), what ties the files together in the code, and
a concrete proposal named in the repository's own vocabulary (move, merge, extract an entry point, give a concept one
home). Some Splits are deliberate boundaries, such as frontend and backend changing together for a feature; name
those as such rather than proposing to remove them.

## 8. Before merging a branch

To see what the current branch would do once merged, call `pending_change`, or run:

```bash
codespread <repository> --pending                     # against main, else master
codespread <repository> --pending --base origin/main  # another base; in CI the base is often only a remote branch
```

It takes the branch's work since it left the base, committed or not, as one change on the base's tip, the way a
squash-merge lands it. Its first lines say how that change moves the repository's Spread and how far it spreads
against a typical change here; below them is the repository's page with the branch merged. Read
[INTERPRETING.md](INTERPRETING.md#what-a-branch-does) for what they mean. Use it for a refactoring in progress, and to
review a branch: a change that spreads further than typical is worth a look at the Splits it crosses, not a verdict.

## 9. After a refactoring

To see what a refactoring already on the main branch did, take the page of a commit from before it and compare the
two: the Spread, and the Spread contribution of the Splits and Pairs in question.

```bash
git -C <repository> worktree add --detach "${TMPDIR:-/tmp}/codespread-before" <commit>
codespread "${TMPDIR:-/tmp}/codespread-before" --path <folder>
git -C <repository> worktree remove "${TMPDIR:-/tmp}/codespread-before"
```

Then take the same page of the checkout. Uncommitted work counts as one change, so a refactoring in progress shows at
once. Its full effect appears gradually, as later changes follow the new structure: recent changes weigh most, with a
half-life of six months.

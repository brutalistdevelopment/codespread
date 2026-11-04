# Interpreting a CodeSpread page

**Spread** is how far the work of a typical change spreads through the directory tree, compared with random placement.
The first line gives it for the whole repository: 0 means work stays in one folder, 1 means the folders say nothing
about what changes together. Every other number on the page is a share of it, so numbers on different pages of the
same Snapshot compare directly.

```
Snapshot of dadb813bf481, committed 2026-11-03 · Spread 0.61 ± 0.02 · taken in 0.37 s

(root)

Where changes split                                                           Spread contribution
  (root): app <-> workers                                                                  0.1291
  app: billing <-> shipping                                                                0.0744

Pairs with the most Spread
  0.0100  app/billing/invoice.py <-> workers/billing/send_invoice.py
```

## The summary

The line under the header names the page. On a folder's or file's page it also gives:

- **Contained**: the share of work that stays inside this folder.
- **Crossing**: the share of work that touches this folder or file and somewhere outside it.

A folder with high Crossing and low Contained is not a unit of work: most changes that touch it also touch something
else. The partner areas say what.

## Where changes split

`folder: a <-> b` is a folder and the two of its entries where co-changing files most often part ways. The folder is
where the work spreads; `a` and `b` are the directions it goes. Open the page of `folder/a` or `folder/b` to see the
files behind it.

- A Split at `(root)` between two top-level folders often means a feature lives on both sides of a boundary. Check
  whether that boundary is deliberate (frontend and backend, an API and its consumers) or accidental.
- A Split inside one folder often points at one concept split across both entries. Moving it to one place shrinks
  the Split.

## Pairs with the most Spread

Two files that keep changing together across distance. These are the files to read. Several Pairs sharing one file
point at that file as the thing everything else follows.

## Partner areas

On a folder's or file's page, where its crossing work goes outside it. A folder's own Splits only show what happens
inside it, so when its Crossing is much larger than its Splits, the finding is here: the folder and its main partner
area change as one, and the boundary between them is in the wrong place or carries a leaking concept.

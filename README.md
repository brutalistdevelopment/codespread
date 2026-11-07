# CodeSpread

by [Brutalist Development](https://brutalistdevelopment.org)

CodeSpread finds what makes a codebase expensive to change. From a repository's git history it measures how far the
work of a typical change spreads across the directory tree, compared with random placement, and shows where: the
folders where co-changing files part ways and the files that keep changing together across distance. It works on git
repositories in TypeScript, JavaScript, Python and Rust.

This repository holds what connects CodeSpread to your tools. The analysis itself is the `codespread` npm package
and the `brutalistdevelopment/codespread` Docker image.

## Claude Code plugin

```
/plugin marketplace add brutalistdevelopment/codespread
/plugin install codespread@codespread
```

The plugin brings the `codespread` MCP server, run with `npx` (Node 24 or later), and a skill that takes a Snapshot,
reads it and turns its findings into concrete refactoring proposals. Then ask, for example, "what makes this
repository expensive to change?"

## Other agents

[`skills/codespread/`](skills/codespread/SKILL.md) is a skill in the Agent Skills format. Copy it into your agent's
skills folder, and add the MCP server:

```bash
npx -y codespread mcp      # an MCP server over stdio for the repository in the current folder
```

## The command line

```bash
npx codespread                    # the report of the repository in this folder
npx codespread --path src/api     # one folder or file
```

Or through Docker, with the repository mounted read-only:

```bash
docker run --rm -v "$PWD:/repo:ro" brutalistdevelopment/codespread .
```

The analysis reads the full history, so in CI check out with `fetch-depth: 0`.

## Licence

The contents of this repository are MIT licensed. The `codespread` package and image are licensed separately.

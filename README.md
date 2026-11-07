# CodeSpread

by [Brutalist Development](https://codespread.brutalistdevelopment.org)

Code that changes together should live together.

CodeSpread puts a number on that principle. From a repository's git history, it measures how far the files in a typical change are spread across the directory tree, compared with random placement. It quantifies the principles of cohesion and couping that Dave Farley sets out in the book Modern Software Engineering.

The report shows where your code structure works against you: the folders where changes split across boundaries, and the distant files that are coupled in practice. It works on git repositories in TypeScript, JavaScript, Python and Rust.

This repository holds what connects CodeSpread to your tools. The analysis itself is the `codespread` npm package and the `brutalistdevelopment/codespread` Docker image.

CodeSpread is an independent project and is not affiliated with or endorsed by Dave Farley.

## GitHub Action

On every pull request, CodeSpread comments how the change spreads its work compared with a typical change in the repository, and how it will affect the total Spread. Each run replaces the previous comment, and the job
summary gets the same report.

```yaml
name: CodeSpread
on: pull_request
permissions:
  contents: read
  pull-requests: write
jobs:
  codespread:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: brutalistdevelopment/codespread@v1
```

| Input | Default | |
|---|---|---|
| `base` | the pull request's base branch | the branch the work merges into |
| `limit` | `10` | how many entries each list shows |
| `comment` | `true` | `false` keeps the report in the job summary only |
| `version` | the release this action was tagged with | the `codespread` package to run |

Pull requests from forks get a read-only token, so they have the job summary but no comment.

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

# Claude Statusline Customization

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Repository: https://github.com/AbeSaldana/Claude-Statusline

Notes on how my Claude Code status line is set up: which files to edit, what each segment shows, and a log of changes.

## Preview

```
[Opus 5.5 · high] | 📁 Claude-Statusline | main | ctx ▓▓░░░░░░░░ 18% | 5h ▓░░░░░░░░░ 9% | 7d ▓▓▓░░░░░░░ 27% | $1.42
```

## Repo layout

```
Claude-Statusline/
├── README.md
├── LICENSE                  # MIT License
├── .gitattributes           # Line-ending rules (shell scripts always use LF)
├── statusline.sh            # The status line script (source of truth)
├── settings.example.json    # The statusLine snippet for ~/.claude/settings.json
├── .gitignore
├── examples/                # Sample JSON inputs, like the ones Claude Code sends
│   ├── normal.json          #   all bars green
│   ├── warning.json         #   some bars yellow (>= 70%)
│   ├── limit.json           #   all bars red (>= 90%)
│   └── minimal.json         #   only model + folder (optional fields missing)
└── scripts/
    ├── install.sh           # Copy statusline.sh to ~/.claude and configure settings.json
    ├── test.sh              # Render every example (or the files you pass in)
    └── sync.sh              # Copy the live ~/.claude/statusline.sh back into the repo
```

## Quick start

```bash
git clone https://github.com/AbeSaldana/Claude-Statusline.git
cd Claude-Statusline
./scripts/test.sh      # preview the status line using the examples
./scripts/install.sh   # install it into ~/.claude
```

`install.sh` needs `jq`. Before changing anything, it backs up your existing `statusline.sh` and `settings.json` as `*.<timestamp>.bak`. It only sets the `statusLine` key and leaves your other settings alone, and running it again is safe.

### Workflow for changes

1. Edit `statusline.sh` in the repo.
2. Run `./scripts/test.sh` to check the output.
3. Run `./scripts/install.sh` to apply it.
4. Add a row to the [Changelog](#changelog).

If you edited `~/.claude/statusline.sh` directly, run `./scripts/sync.sh`. It shows a diff and copies the live script back into the repo.

## Files that get installed

| File | Purpose |
|------|---------|
| `~/.claude/settings.json` | Points Claude Code at the status line script (`statusLine` key). |
| `~/.claude/statusline.sh` | The script that builds the status line text. Copied from this repo's `statusline.sh`. |

### 1. `~/.claude/settings.json`

The `statusLine` entry tells Claude Code which command to run:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

Optional keys:
- `"padding": 0`: removes the default horizontal padding.

Changes to `settings.json` apply right away. Edits to `statusline.sh` show up on the next status line refresh, with no restart needed.

### 2. `~/.claude/statusline.sh`

Claude Code pipes a JSON object to the script on **stdin**. The script reads fields with `jq` and prints a single line (ANSI colors are supported) to **stdout**.

## Segments

| Segment | JSON field | Notes |
|---------|-----------|-------|
| Model | `.model.display_name` | Shown as `[Model · effort]` |
| Effort | `.effort.level` | Left out when empty |
| Folder | `.workspace.current_dir` (falls back to `.cwd`) | Basename only, with a 📁 prefix |
| Git branch | `git branch --show-current` | Uses `--no-optional-locks` so it never blocks git; hidden outside a repo |
| Context | `.context_window.used_percentage` | Progress bar labeled `ctx` |
| 5-hour limit | `.rate_limits.five_hour.used_percentage` | Progress bar labeled `5h` |
| 7-day limit | `.rate_limits.seven_day.used_percentage` | Progress bar labeled `7d` |
| Cost | `.cost.total_cost_usd` | Session cost, 2 decimals |

Any segment with an empty value is skipped.

## Settings in the script

These variables are defined at the top of `statusline.sh`:

| Variable | Default | Meaning |
|----------|---------|---------|
| `BLUE` | `\033[1;38;5;33m` | Bold blue (#0087ff): model, folder, branch, cost |
| `GREEN` | `\033[1;38;5;28m` | Bold dark green (#008700): bars below `WARN` |
| `YELLOW` | `\033[1;38;5;220m` | Bold yellow: bars at or above `WARN` |
| `RED` | `\033[1;91m` | Bold bright red: bars at or above `LIMIT` |
| `DIM` | `\033[90m` | Gray `|` separators |
| `WARN` | `70` | % where a bar turns yellow |
| `LIMIT` | `90` | % where a bar turns red |
| `BAR_WIDTH` | `10` | Number of cells per bar (`▓` filled, `░` empty) |

## Testing

```bash
./scripts/test.sh                       # all examples
./scripts/test.sh examples/limit.json   # a single example
bash statusline.sh < examples/normal.json
```

To cover a new case, add a JSON file to `examples/` and `test.sh` will pick it up automatically.

## Requirements

- `bash`
- `jq` (`/usr/bin/jq` on macOS, or `brew install jq`)
- `git` (only for the branch segment)
- A terminal with 256-color support and emoji fonts

## Changelog

| Date | Change | Files |
|------|--------|-------|
| 2026-11-01 | Started documenting the existing setup: model/effort, folder, branch, ctx/5h/7d progress bars with color thresholds, and cost. | `README.md` |
| 2026-11-01 | Set up the repo: added the script, example inputs, and the install/test/sync scripts. | `statusline.sh`, `settings.example.json`, `examples/*`, `scripts/*`, `.gitignore` |

| 2026-11-01 | Added the MIT License. | `LICENSE`, `README.md` |

| 2026-11-01 | Published to GitHub; added the repo URL and clone steps, plus `.gitattributes` rules forcing LF line endings. | `README.md`, `.gitattributes` |

<!-- Add a row for each change, e.g.:
| YYYY-MM-DD | Description of the change | `~/.claude/statusline.sh` |
-->

## License

Released under the [MIT License](LICENSE).

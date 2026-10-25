# REA Reverse-Engineering Lab

Ade's hands-on lab for learning reverse engineering (RE) with
[REA](https://github.com/morluto/rea). Every Claude Code session in this repo runs
as the **rea-ade-agent** tutor (set in `.claude/settings.json`).

## What's what
| Piece | What it is | Where |
|---|---|---|
| **REA** (`rea`) | CLI + MCP server that lets AI agents inspect compiled software | `npm i -g rea-agents` |
| **REA MCP server** | Gives Claude ~229 RE tools (`mcp__rea__*`) | registered in `~/.claude.json` |
| **REA skill** | Instructions telling Claude *how* to investigate with REA | `~/.claude/skills/reverse-engineer-anything` |
| **Ghidra 12.1.4** | Free NSA decompiler; REA's engine for native binaries | `/opt/ghidra_12.1.4_PUBLIC` |
| **Rizin, objdump, gdb** | Lightweight disassembler / debugger tools | on `PATH` |
| **rea-ade-agent** | Your RE tutor agent | `.claude/agents/rea-ade-agent.md` |

## Setup
`setup-rea.sh` installs everything (~5 min) and builds the lesson binaries.
Set `bash setup-rea.sh` as this repo's **cloud environment setup script** on
claude.ai/code so it runs automatically before each session starts.

## Lessons
1. **`01-crackme/`: Find the valid ticket code.** `crackme-stripped` is a tiny
   ticket validator with its function names removed. Goal: find the code that prints
   `ACCESS GRANTED`, **without opening `crackme.c`**.
   Concepts: ELF files, strings, entry point, `main`, decompilation, `strcmp`.

Start by saying: *"Start lesson 1."*

## Rules of the lab
Only analyze software you own, built yourself, or are explicitly authorized to
examine (CTFs, crackmes, open source, your company's apps with permission).

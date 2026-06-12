---
description: Stage all changes and commit with an auto-generated conventional commit message
---

Stage all current changes and create a git commit. Follow these steps exactly:

1. Run `git status` to see what has changed. If there is nothing to commit, report that and stop.
2. Run `git diff` and `git diff --staged` to understand what changed.
3. Run `git log --oneline -5` to match the existing commit message style.
4. Stage all relevant files. Skip any `.env` files, credential files, or files containing secrets.
5. Write a concise commit message that follows the existing style in this repo. Focus on WHY the change was made, not just what files changed. End the message with:
   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
6. Commit and report the commit hash and message.

Do not push — only commit locally.

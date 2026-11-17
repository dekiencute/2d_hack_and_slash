# Codex → Godot → Director playtest → GitHub

## Safe initial rollout
1. Codex specialists implement isolated tasks in worktrees and the Lead Agent reviews/integrates them locally.
2. Before any push, on Windows: `py -3 .\tools\release.py`. This existing script runs technical validations and produces a Windows release-candidate ZIP.
3. The Game Director opens the locally produced build and signs off **one exact commit SHA**.
4. On approval, the Lead Agent may push that approved candidate to a feature branch and open a **draft pull request**, never directly to `main`.
5. The PR automatically triggers `.github/workflows/playtest-build.yml`, repeating the project build/validation and uploading a Windows ZIP as a GitHub Actions artifact.
6. Review the PR status and release candidate. Human sign-off is still required. No automatic merge or publication has been enabled.

## Important limitations
- GitHub Actions cannot run on code that has never been pushed. Pre-push validation/playtest must happen locally.
- The GitHub Actions build is a technical smoke/regression test, not a real human gameplay feel test.
- Workflow artifact downloads are QA distribution, not a public game release.
- The existing `tools/release.py` reports incomplete license evidence without blocking private technical builds. This is **not** permission for public redistribution.
- A Director approval must record a commit SHA and build checksum. If files change after approval, re-test and re-approve.

## Director approval record
- Feature / issue:
- Candidate commit SHA:
- Windows build ZIP SHA256:
- Godot automated checks: PASS / FAIL
- Visual & input playtest: PASS / FAIL
- Asset changes / rights status:
- Decision: APPROVE / REJECT
- Notes:

## Next rollout items
- Wire a local approval button/script to commit-SHA + ZIP-hash verification; avoid blind pushes.
- Configure branch rules / required checks in repository settings.
- Only when stable, optionally automate merging approved PRs into a development branch, not directly into the protected release branch.

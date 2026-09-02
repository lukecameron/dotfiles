When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.

For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.

When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible. This makes sure you find the real problem so your fix will actually solve it.

When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection. If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.

Apply that same high standard to engineering excellence: lint, test failures, and test flakiness. If you see one, even if it is not caused by what you are working on right now, still get it fixed.

When referring to a pull request, issue, or ticket, never give the bare number alone. Always follow it with a short description of what it is, for example `#7123 (retry failed webhook deliveries)`, so the reader can keep track when several are being discussed at once.

For long-running commands and external processes, keep progress observable and persist intermediate results often enough that an interruption loses minutes, not hours. Track the exact process or session; do not infer completion from broad process-name matching.
{{- if eq .machineName "slate-pro" }}

Keep pull requests in draft if they contain any public-facing documentation or copy that needs approving. The team is sensitive to noticeable LLM-isms in public-facing text, so have me proofread that copy before marking the PR ready for review or proceeding automatically.
{{- end }}

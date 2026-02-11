---
date: {{DATE}}
title: {{TITLE}}
---

# {{TITLE}}

## Evidence Status
**{{STATUS}}**
*(Options: VERIFIED | PARTIALLY VERIFIED | UNVERIFIED)*
*Rule: VERIFIED requires all Minimal Proofs with artifacts. PARTIALLY VERIFIED allowed only if Summary notes "pending verification".*

## Summary
{{BRIEF_SUMMARY}}

## Minimal Proof Pack (Mandatory)
*Must be included to claim implementation success.*

### 1. Code Proof (Repo Artifacts)
*   **Skill/Docs**: `path/to/file` - {{CHANGE_DESCRIPTION}}
*   **Implementation**: `path/to/code` - {{CHANGE_DESCRIPTION}}
*   **Commit**: `{{COMMIT_HASH}}` (If Pending, status cannot be VERIFIED)

### 2. Routing Proof (End-to-End Trace)
*   **Artifacts**: {{SCREENSHOT_OR_HAR_FILENAME}}
*   **Browser (Network Tab)**:
    *   URL: `{{REQUEST_URL}}`
    *   Status: `200 OK`
    *   Response Snippet: `{{JSON_SNIPPET}}`
*   **Backend (n8n/Worker)**:
    *   Execution ID: `{{EXECUTION_ID}}`

### 3. Contract Proof
*   Parser: Matches `{{PARSER_FUNCTION_NAME}}` expectations.
*   Required Fields: `{{LIST_REQUIRED_FIELDS}}` matched.

### 4. Security Proof
*   **Artifact**: {{NETWORK_HEADERS_IMAGE_OR_DUMP}}
*   **Condition**: Verified Request Headers do NOT contain `x-webhook-shield`.

## Full Proof Pack (Optional/Hardening)
*   [ ] **Negative Tests**: Direct n8n access returns 401/403.
*   [ ] **Rate Limits**: Exceeding policy returns 429.
*   [ ] **Prod Behavior**: Missing env var triggers fail-closed state.
*   [ ] **Multi-surface**: Verified routing for second surface ID.

## Implementation Details
{{DETAILS}}

## Next Steps
*   {{NEXT_STEP_1}}
*   {{NEXT_STEP_2}}

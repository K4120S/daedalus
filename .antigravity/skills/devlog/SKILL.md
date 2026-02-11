---
name: devlog
description: Create development log entries with mandatory proof packs for verifying implementation claims.
allowed-tools: read_file write_to_file run_command
---

# Devlog Skill

This skill enforces a rigorous standard for development logging. Every implementation claim MUST be accompanied by a **Minimal Proof Pack**.

## Usage

1.  **Create Entry**: Use `assets/template_entry.md`.
2.  **Plan Verification** (Gate 1): Before gathering proofs, present a verification plan to the user:
    *   List specific artifacts needed (which diffs, which endpoints to test, which screenshots)
    *   Define acceptance criteria for each proof type
    *   Identify scope boundaries (what is testable vs. requires deployment)
    *   Specify stop conditions (max attempts, fallback to UNVERIFIED)
    *   **STOP**: Wait for user approval
3.  **Gather Proofs**: Execute approved verification plan, collect evidence artifacts.
4.  **Determine Status**:
    *   **VERIFIED**: All Minimal items present with concrete artifacts.
    *   **PARTIALLY VERIFIED**: Code proof present, but routing missing (Summary must say "pending verification").
    *   **UNVERIFIED**: Anything else (including if verification plan exceeded scope or hit stop conditions).

## Proof Packs

### Minimal Proof Pack (Mandatory)
required for any claim of "gate implemented" or "skill created".

1.  **Code Proof**:
    *   **Requirement**: Diffs or Commit Hash.
    *   **Rule**: If Commit is "Pending", status cannot be VERIFIED.

2.  **Routing Proof**:
    *   **Requirement**: Concrete artifact (Screenshot, HAR, or Header dump).
    *   **Browser**: Network fields (URL, Status, Response).
    *   **Backend**: n8n Execution ID or Timestamp.
    *   **Rule**: "Browser -> 200 OK" text alone is insufficient.

3.  **Contract Proof**:
    *   **Requirement**: Explicit match against frontend parser expectations.

4.  **Security Proof**:
    *   **Requirement**: Network artifacts showing **NO** `x-webhook-shield` in browser request.

### Full Proof Pack (Optional/Hardening)
Recommended for regression testing but not strictly required for initial "it works" claim.

A. **Worker Observability**: Logs, Matcher, Forwarding, CORS.
B. **Security Negative Tests**: 401/403 on direct n8n calls; 400 on malformed payloads; Rate limits.
C. **Multi-surface**: Routing verification across multiple IDs.
D. **Data Integrity**: Persistence of `contactInfo` across reloads.
E. **Production Gates**: Fail-closed checks (~`VITE_WEBHOOK_BASE_URL`).
F. **Docs Consistency**: `GATES.md` vs Code parity.

## Verification Scope Boundaries

**Agents CAN verify locally:**
- Code diffs (git/filesystem)
- Local build/lint/test results
- Local dev server endpoints (localhost)
- Browser DevTools artifacts (Network tab, Console)

**Agents CANNOT verify (require user or deployment):**
- Production endpoints
- Cloudflare Workers/Pages behavior
- n8n webhook execution
- Secrets/environment variables in deployment
- Cross-origin requests (unless local CORS proxy exists)

**Stop Conditions:**
- If verification requires deployment → Mark **PARTIALLY VERIFIED**, request user deployment
- If verification requires backend access → Mark **UNVERIFIED**, escalate to user
- Max 2 verification attempts per proof type (Rule of Two)

## Claim Gating Rules
*   If Minimal Proof Pack is incomplete -> Status must be **UNVERIFIED**.
*   Summary must **NOT** claim "implemented" if status is UNVERIFIED.
*   "PARTIALLY VERIFIED" allows "implemented wiring" claims but must explicitly state "pending verification".
*   If verification plan was not approved → Cannot gather proofs (escalate to user first).

## Templates

*   [Devlog Entry Template](assets/template_entry.md)

## Feature Naming

When documenting features in devlog entries, use canonical names from the **[Naming Registry](../../docs/NAMING_REGISTRY.md)**:
- Reference features by their **Generic Name** (e.g., "Landing Page Agent")
- Include **Working Title** in parentheses if relevant (e.g., "Landing Page Agent (Agent Zero)")
- Avoid using code artifact names (e.g., `SalesAgentModal`) unless specifically discussing implementation details


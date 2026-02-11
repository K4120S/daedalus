# UI Debug Report: [Brief Issue Title]

**Timestamp**: [ISO 8601 timestamp, e.g., 2026-01-14T17:00:00Z]  
**Target URL**: [URL tested, e.g., http://localhost:5173/contact]  
**Component/Flow**: [UI element or flow name, e.g., "Contact Form Submission"]

> **Note**: Evidence below collected autonomously via browser_subagent (`capture_browser_console_logs`, network interceptors, screenshots)

---

## Summary
[1-2 sentence description of the issue. Example: "Contact form submission fails with 403 error. Expected success toast does not appear."]

---

## Expected vs Actual

**Expected**: [What should happen. Example: "Form submits successfully, POST to /webhooks/public/contact/submit returns 200, success toast appears."]

**Actual**: [What did happen. Example: "Form submits, but POST returns 403 Forbidden. No toast appears. Console shows error."]

---

## Reproduction Steps

1. [Step 1. Example: "Navigate to http://localhost:5173"]
2. [Step 2. Example: "Fill contact form (name, email, company, message)"]
3. [Step 3. Example: "Click Submit button"]
4. [Continue as needed...]

---

## Console Evidence

### Errors
- **[Timestamp]** [Error 1 with full message and stack trace]
  ```
  [Full error text here]
  Stack trace:
    at [file:line]
    at [file:line]
  ```
- **[Timestamp]** [Error 2...]

### Warnings
- **[Timestamp]** [Relevant warning 1]
- **[Timestamp]** [Relevant warning 2]

### Screenshots
- [Reference to screenshot files, e.g., `console-error-2026-01-14.png`]

---

## Network Evidence

### Failed Requests

**Request 1:**
- **URL**: [Full URL, e.g., `http://localhost:8787/webhooks/public/contact/submit`]
- **Method**: [e.g., POST]
- **Status**: [e.g., 403 Forbidden]
- **Timing**: [e.g., 245ms or "Request blocked immediately"]
- **Response Preview**:
  ```
  [First 200 chars of response or full error message]
  ```

**Request 2:**
[Repeat structure if multiple failures]

### CORS/Blocked Issues
[Details if applicable, e.g., "Preflight OPTIONS request failed with CORS policy error"]

### HAR Captured
**Yes** / **No**

If Yes:
- **File Path**: [e.g., `docs/debug-artifacts/2026-01-14-contact-form-403.har`]
- **Note**: Sanitized by default (cookies, auth headers removed)

---

## Working Hypotheses

1. [Hypothesis 1 based on evidence. Example: "Turnstile token is missing from the request payload, causing Worker to reject with 403."]
2. [Hypothesis 2. Example: "CORS headers are misconfigured, blocking the preflight request."]
3. [Hypothesis 3. Example: "Worker expects a specific header (x-webhook-shield) that is not being sent from the UI."]

---

## Next Best Diagnostic

[Single smallest next step to gather more evidence. Example: "Check browser DevTools Network tab for request payload to confirm Turnstile token presence. If missing, inspect SalesAgentModal.tsx Turnstile widget initialization."]

---

## Recommended Code Areas

- [File/component 1 to inspect. Example: `src/components/SalesAgentModal.tsx` (Turnstile widget)]
- [File/component 2. Example: `src/api/agents.ts` (sendToWebhookShield function)]
- [File/component 3. Example: `worker/index.ts` (Turnstile verification logic)]

---

**End of Report**

---

## Usage Example

**Scenario**: Test contact form submission

**User Request**: "Test the contact form submission. It should POST to /webhooks/public/contact/submit and show a success toast."

**Agent Workflow (Autonomous)**:

1. **Network Interceptor Injection**:
   - Tool: `execute_browser_javascript`
   - Injects fetch/XHR monkey-patch to log requests to console

2. **Browser Subagent Execution**:
   - TaskName: "Submit Contact Form"
   - RecordingName: `contact_form_submit`
   - Actions: Navigate to page, fill form, click Submit, wait for response

3. **Console Log Capture**:
   - Tool: `capture_browser_console_logs`
   - Captured:
     ```
     [log] NETWORK_FETCH_REQUEST: https://hooks.example.com/webhooks/public/contact/submit {method: POST, ...}
     [log] NETWORK_FETCH_RESPONSE: 403
     [error] Failed to submit: Turnstile verification failed
     ```

4. **Screenshot Capture**:
   - Tool: `capture_browser_screenshot`
   - Shows error state (no success toast)

5. **Report Generated**:
   - **Summary**: Contact form POST returns 403, no success toast shown
   - **Console Error**: "Turnstile verification failed"
   - **Network**: POST to hooks.example.com/webhooks/public/contact/submit → 403
   - **Hypothesis**: Turnstile token missing or invalid in request payload
   - **Recommended Code Area**: `src/components/SalesAgentModal.tsx` (Turnstile widget initialization)
   - **Recording**: `artifacts/contact_form_submit.webp`

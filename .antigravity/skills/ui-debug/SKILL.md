---
name: ui-debug-browser-task
description: Autonomous protocol for debugging UI issues using browser_subagent. Captures console logs, intercepts network requests, takes screenshots, and produces paste-ready debug reports. Fully autonomous - no manual DevTools required.
allowed-tools:
  - browser_subagent
  - read_file
  - write_to_file
---

# UI Debug Browser Task Skill (Autonomous)

**Autonomous debugging protocol** using browser_subagent capabilities to capture console logs, intercept network requests, and produce comprehensive debug reports without manual intervention.

## A) Goal

Autonomously debug UI elements/flows by:
1. Using `browser_subagent` to reproduce the issue
2. Injecting network interceptors to capture API requests
3. Capturing console logs programmatically
4. Taking screenshots of UI state
5. Producing paste-ready debug report with evidence

## B) Browser Subagent Capabilities

### Available Tools
- ✅ **`capture_browser_console_logs`**: Programmatically retrieve ALL console output (errors, warnings, logs, debug, info)
- ✅ **`execute_browser_javascript`**: Inject observability hooks (network interceptors, event listeners)
- ✅ **`capture_browser_screenshot`**: Visual proof of UI state
- ✅ **`browser_get_dom`**: DOM structure inspection
- ✅ **`read_browser_page`**: Page content and metadata

### Cloudflare Wrangler Tail (For Webhook Flows)

**Purpose**: Capture Worker-level logs when UI interacts with Cloudflare Worker endpoints (e.g., `hooks.example.com`)

**Command**:
```bash
# For full request/response metadata
wrangler tail boas-webhook-shield --format json

# For explicit console.log output (if Worker has logging)
wrangler tail boas-webhook-shield --format pretty --status
```

**When to Use**:
- UI makes requests to `https://hooks.example.com/webhooks/*`
- Need to verify Worker routing, headers, or response status
- Debugging CORS, rate limiting, or security errors
- Correlating UI requests with backend behavior

**Integration with Browser Debugging**:
1. Start `wrangler tail` in background terminal
2. Execute browser_subagent UI interaction
3. Capture both browser console logs AND wrangler tail output
4. Correlate via CF-Ray ID (in response headers and tail logs)

**Evidence Captured**:
- Request URL, method, headers (from Worker perspective)
- Response status, headers (including x-webhook-shield)
- Worker execution time (wallTime, cpuTime)
- Client IP, geolocation, ASN
- CF-Ray ID for correlation with browser logs

### Network Request Interception
**Method**: Inject fetch/XHR monkey-patch via `execute_browser_javascript`

```javascript
(function() {
  const originalFetch = window.fetch;
  window.fetch = function() {
    console.log('NETWORK_FETCH_REQUEST:', arguments[0], arguments[1]);
    return originalFetch.apply(this, arguments).then(response => {
      console.log('NETWORK_FETCH_RESPONSE:', response.url, response.status);
      return response;
    });
  };

  const originalOpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function() {
    console.log('NETWORK_XHR_REQUEST:', arguments[0], arguments[1]);
    originalOpen.apply(this, arguments);
  };
})();
```

Then use `capture_browser_console_logs` to retrieve logged requests.

## C) Inputs

### Required
- **Target URL**: Page to debug (localhost or production)
- **UI Element/Flow**: Specific element or user flow to test
- **Expected Behavior**: What should happen vs what's happening

### Optional
- **Repro Steps**: Known reproduction steps
- **User/Session State**: Login requirements, feature flags
- **Endpoints to Monitor**: Specific API endpoints to watch

## D) Execution Steps (Autonomous)

### Step 0: Start Wrangler Tail (For Webhook Flows Only)
**When**: UI flow involves requests to `https://hooks.example.com/webhooks/*`

```bash
wrangler tail boas-webhook-shield --format json
```

**Keep running** in background during browser_subagent execution.

### Step 1: Inject Network Interceptor
- Use `execute_browser_javascript` to inject fetch/XHR monkey-patch
- Logs all network requests to console with URL, method, status

### Step 2: Execute Reproduction via browser_subagent
- Navigate to target URL
- Perform UI interaction (click button, submit form, etc.)
- Wait for completion (API response or error state)

### Step 3: Capture Console Logs
- Use `capture_browser_console_logs` to retrieve:
  - JavaScript errors with stack traces
  - Console warnings
  - Network request logs from interceptor
  - Custom debug logs

### Step 4: Capture Wrangler Tail Output (If Running)
- Check wrangler tail terminal for JSON logs
- Find log entry matching request timestamp
- Extract CF-Ray ID, status, execution metrics
- **Correlation**: Match CF-Ray ID from browser Network tab with tail logs

### Step 5: Take Screenshot
- Use `capture_browser_screenshot` to capture final UI state
- Shows error messages, modals, or unexpected state

### Step 6: Inspect DOM (if needed)
- Use `browser_get_dom` to verify element presence
- Check for visibility issues or missing elements

### Step 7: Generate Debug Report
- Compile evidence into paste-ready format
- Include console errors, network requests, screenshots
- Include Wrangler tail excerpt (if applicable)
- Provide hypotheses and recommended code areas

## E) Evidence Capture (Autonomous)

### Console Evidence
**Tool**: `capture_browser_console_logs`

**Captures**:
- All JavaScript errors with stack traces
- Console warnings and deprecation notices
- Injected network request logs
- Custom debug output
- Timestamps

### Network Evidence
**Tool**: `execute_browser_javascript` (interceptor) + `capture_browser_console_logs`

**Captures**:
- Request URL, method, headers (from interceptor log)
- Response status code
- Response timing
- CORS errors (visible in console)

**Example Console Output**:
```
[log] NETWORK_FETCH_REQUEST: https://api.example.com/endpoint {method: POST, headers: {...}, body: {...}}
[log] NETWORK_FETCH_RESPONSE: https://api.example.com/endpoint 403
```

### Wrangler Tail Evidence (Webhook Flows)
**Tool**: `wrangler tail boas-webhook-shield --format json`

**Captures**:
```json
{
  "outcome": "ok",
  "scriptName": "boas-webhook-shield",
  "event": {
    "request": {
      "url": "https://hooks.example.com/webhooks/public/agent-skills/inquiry.send",
      "method": "POST",
      "headers": {
        "cf-ray": "9be86c192dc08657",
        "origin": "https://example.com"
      }
    },
    "response": {
      "status": 200
    }
  },
  "wallTime": 1771,
  "cpuTime": 4
}
```

**Correlation Key**: CF-Ray ID (e.g., `9be86c192dc08657`) appears in:
- Browser Network tab headers
- Wrangler tail JSON output
- curl response headers

**When to Include**: Any UI flow that calls `https://hooks.example.com/webhooks/*`

### Visual Evidence
**Tool**: `capture_browser_screenshot`

**Captures**:
- Final UI state
- Error modals or toasts
- Layout issues
- Missing elements

### DOM Evidence
**Tool**: `browser_get_dom`

**Captures**:
- Interactive elements in viewport
- Element presence verification
- Structural issues

## F) Stop Conditions / Retry Caps

**Retry Rules**:
- **Total attempts: 2** (initial + max 1 retry)
- Retry ONLY if new evidence emerges (different error, different state)

**Escalation Triggers**:
- Same console error after 2 attempts
- Network request succeeds but UI behaves incorrectly (logic bug - requires code analysis)
- Issue requires production deployment to verify
- Issue requires backend logs not accessible via browser

## G) Output Format (Paste-Ready)

Use template from [`resources/BUG_REPORT_TEMPLATE.md`](resources/BUG_REPORT_TEMPLATE.md).

**Required sections**:
- Summary (1-2 lines)
- Expected vs Actual
- Reproduction Steps
- Console Evidence (errors + warnings + network logs)
- Network Evidence (intercepted requests + responses)
- Screenshots (embedded with `![](path)`)
- Working Hypotheses (2-3)
- Next Best Diagnostic
- Recommended Code Areas

## H) Safety & Redaction

**Never Include**:
- API keys, tokens, secrets
- User passwords or credentials
- Session cookies
- Authorization headers
- PII unless essential and redacted

**Request/Response Sanitization**:
- Redact `Authorization`, `Cookie`, `Set-Cookie` headers from logs
- Redact tokens in query params (`?api_key=...`)
- Redact session IDs, user IDs if not essential

## Usage Example

**User Request**: "Test contact form submission - should POST to /webhooks/public/contact/submit"

**Agent Actions**:
1. Injects network interceptor via `execute_browser_javascript`
2. Uses `browser_subagent` to fill form and click Submit
3. Captures console logs via `capture_browser_console_logs`:
   ```
   [log] NETWORK_FETCH_REQUEST: https://hooks.example.com/webhooks/public/contact/submit {method: POST, ...}
   [log] NETWORK_FETCH_RESPONSE: 403
   [error] Failed to submit: Turnstile verification failed
   ```
4. Takes screenshot showing error state
5. Generates report:
   - **Issue**: 403 Forbidden on POST
   - **Hypothesis**: Turnstile token missing from payload
   - **Recommended**: Inspect `SalesAgentModal.tsx` Turnstile widget

## Templates

- [Bug Report Template](resources/BUG_REPORT_TEMPLATE.md)

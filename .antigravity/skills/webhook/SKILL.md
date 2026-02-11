---
name: webhook
description: Generate code and configurations for new webhook integrations (Gates) following the canonical routing schematic.
allowed-tools: read_file write_to_file
---

# Webhook Skill

This skill helps you create new "Gates" for public-facing webhooks. A Gate consists of a UI client, a Cloudflare Worker route, and an n8n workflow.

## Pre-requisites

*   Familiarize yourself with the [Canonical Routing Map](docs/webhooks/GATES.md).

## Usage

When adding a new webhook action (e.g., `inquiry.send`):

1.  **Define the Action**: Determine the action name `<action>` (e.g., `inquiry.send`).
2.  **Update Registry**: Add the new action to the Route Registry in `docs/webhooks/GATES.md` with appropriate rate limits.
3.  **Generate Frontend Code**: Use the template in `assets/template_request.ts` to implement the client-side fetch wrapper.
4.  **Worker Config**:
    *   Ensure the action path `/webhooks/public/agent-skills/<action>` is allowlisted in the Worker.
    *   Confirm the Worker injects `x-webhook-shield` when forwarding upstream.
5.  **n8n Implementation**:
    *   Create a workflow with a Webhook Trigger at `/webhook/agent-skills/<action>`.
    *   **Auth**: Configure the Trigger to verify `x-webhook-shield` header.
    *   **Response**: Use a "Respond to Webhook" node set to "Respond with First Entry JSON".
    *   **Contract**: Ensure response JSON matches the [Canonical Response Envelope](docs/webhooks/GATES.md#response-envelope-canonical).

## Guidelines

*   **Browser Security**: The browser NEVER sends secret keys.
*   **Routing**: The browser calls the Worker public route (`/webhooks/public/...`). The Worker forwards to n8n (`/webhook/...`).
*   **Contract**: Always adhere to the standard JSON Request/Response envelopes defined in `docs/webhooks/GATES.md`.

## Templates

*   [Frontend Request Template](assets/template_request.ts)

// Template for a new Webhook Action
// NOTE: This is a TEMPLATE file in .agent/skills/webhook/assets/
// When copied to src/api/, update the import path to: '../api/agents'
// The linting errors below are expected and will resolve when the template is used.

// @ts-expect-error - Template file: import path resolves when copied to src/api/
import type { SalesAgentResponse, SessionMetadata, Identity } from '../api/agents';

export interface ActionNamePayload {
   // Add specific payload fields here
   // e.g., contactInfo?: { name: string; email: string };
   // or draftSummary?: string;
   message?: string;
   [key: string]: unknown;
}

export async function sendActionName(
   payload: ActionNamePayload,
   session: SessionMetadata,
   // Optional: Pass identity explicitly if not derived from session
   identity?: Identity
): Promise<SalesAgentResponse> {
   // @ts-expect-error - Template file: Vite env resolves when copied to src/api/
   const baseUrl = import.meta.env.VITE_WEBHOOK_BASE_URL;
   // Canonical Route: /webhooks/public/agent-skills/<action>
   // TODO: Replace 'action.name' with actual action (e.g., inquiry.send)
   const endpoint = `${baseUrl}/webhooks/public/agent-skills/action.name`;

   // Standard Request Envelope construction (Canonical)
   // Matches docs/webhooks/GATES.md and parsed by src/api/agents.ts
   const body = {
      session: {
         sessionId: session.sessionId,
         username: session.username,
         verifiedAt: session.verifiedAt,
         userAgent: session.userAgent,
         referrer: session.referrer,
         surfaceId: session.surfaceId,
         agentKey: session.agentKey,
         patternContext: session.patternContext,
         contactInfo: session.contactInfo
      },
      identity: identity || {
         sessionId: session.sessionId,
         displayName: session.contactInfo?.name || "Guest",
         client: "example.com",
         surfaceId: "nexus-agent-zero"
      },
      message: payload.message || undefined, // Only for message.send

      // Spread action-specific payload (e.g. draftSummary, contactInfo)
      ...payload,

      history: [], // Populate with actual capped history if needed
      metadata: {
         timestamp: new Date().toISOString(),
         // Add other relevant metadata
      }
   };

   try {
      const response = await fetch(endpoint, {
         method: 'POST',
         headers: { 'Content-Type': 'application/json' },
         body: JSON.stringify(body)
      });

      let responseData;
      const contentType = response.headers.get('content-type');
      if (contentType?.includes('application/json')) {
         responseData = await response.json();
      } else {
         const text = await response.text();
         responseData = { error: text || 'Unknown error' };
      }

      if (!response.ok) {
         // Standard error handling
         const errorMessage = responseData.error || response.statusText;
         throw new Error(`Webhook failed: ${errorMessage}`);
      }

      // Transform to SalesAgentResponse if needed, or return raw data
      // based on the canonical response contract
      return {
         reply: {
            id: `msg-${Date.now()}`,
            role: 'assistant',
            content: responseData.reply,
            createdAt: new Date().toISOString()
         },
         ...responseData
      };

   } catch (error) {
      console.error('ActionName failed:', error);
      throw error;
   }
}

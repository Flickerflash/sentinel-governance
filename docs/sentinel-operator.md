# Sentinel GitHub Operator

Event-driven GitHub App server that detects CI workflow failures and dispatches to the Sentinel/Apogee LLM orchestrator for automated patch PR generation.

## Architecture

```
GitHub Webhook (workflow_run)
  └─ HMAC signature verification
       └─ Idempotency check (deliveryId TTL map)
            └─ handleWorkflowRunEvent
                 ├─ getInstallationToken (cached, 1hr TTL)
                 ├─ fetchFailedJobs
                 ├─ fetchLogTails (302 redirect → S3 zip → AdmZip parse)
                 ├─ fetchWorkflowYAML
                 ├─ callLLMForPatch → Apogee/Sentinel API
                 └─ applyPatchAsPR (branch → commit → PR)
```

## Setup

1. Create a GitHub App with permissions:
   - `actions: read`
   - `contents: write`
   - `pull_requests: write`
   - `metadata: read`

2. Subscribe to `workflow_run` events.

3. Copy `.env.example` to `.env` and fill in credentials.

4. Place your GitHub App private key as `private-key.pem` in the root.

```bash
npm install
npm run dev
```

5. Expose locally with ngrok for webhook testing:
```bash
ngrok http 3000
# Set webhook URL to: https://<your-ngrok-id>.ngrok.io/webhooks/github
```

## Local Test

```bash
curl -X POST http://localhost:3000/webhooks/github \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: workflow_run" \
  -H "X-GitHub-Delivery: test-$(date +%s)" \
  -H "X-Hub-Signature-256: sha256=$(echo -n @test/fixtures/workflow_run_failure.json | openssl dgst -sha256 -hmac $GITHUB_WEBHOOK_SECRET | awk '{print $2}')" \
  -d @test/fixtures/workflow_run_failure.json
```

## LLM Integration (TODO)

Wire `callLLMForPatch()` in `src/server.ts` to your orchestrator endpoint.
Expected contract:
- **Input:** `{ repoOwner, repoName, headBranch, workflowPath, workflowContent, failedJobs, logTails }`
- **Output:** Full corrected YAML string (not a diff) or `null` if no fix available.

## Failure Conclusions Handled

| Conclusion | Handled |
|---|---|
| `failure` | ✅ |
| `timed_out` | ✅ |
| `startup_failure` | ✅ |
| `success` | ❌ (skipped) |
| `cancelled` | ❌ (skipped) |

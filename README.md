# OpenClaw

Personal AI assistant running on Railway, powered by Anthropic Claude.

## What This Is

A self-hosted [OpenClaw](https://openclaw.ai) deployment managed via Terraform.
Handles household admin, email triage, calendar management, and task tracking
via Notion.

## Architecture

- **Runtime:** OpenClaw Gateway on Railway with persistent volume
- **Infrastructure:** Terraform (Railway community provider)
- **AI Provider:** Anthropic Claude (Sonnet 4.6 default, Opus 4.6 available)
- **Channels:** WebChat (built-in), Telegram
- **Integrations:** Gmail, Google Calendar, Google Drive, Notion
- **State Persistence:** Entrypoint script separates config (git) from runtime state (volume)

## Security Model: Least Privilege

OpenClaw uses a **dedicated Google account** (separate from your personal one) to
minimize what the bot can access. Instead of giving it broad access to your
personal account, you share only what it needs:

| Service | What OpenClaw accesses | How access is granted | Scope |
|---|---|---|---|
| **Gmail** | Its own dedicated inbox | OAuth2 on the bot's own account | `gmail.modify` — read, send, label |
| **Google Calendar** | Your personal calendar | You share your calendar with the bot's Gmail | `calendar` — read events, create reminders |
| **Google Drive** | A single shared folder | You create a folder and share it with the bot's Gmail | `drive` — read/write only what's shared |
| **Gmail** *(optional)* | Your personal inbox | You authorize via OAuth2 on your own Google account, granting the bot a refresh token | `gmail.readonly` — read-only access to your personal email; or `gmail.modify` for read/write |

**Key principle:** The OAuth2 credentials authenticate the *bot's own Google account*,
not yours. The bot only sees your calendar and Drive files because you explicitly
shared them — the same way you'd share with a human assistant. You can revoke
access at any time by un-sharing.

## Prerequisites

- A GitHub account
- A personal Google account (for sharing calendar/Drive)
- A Notion account with a Personal Board
- Terraform installed locally (`brew install terraform` on macOS)
- Node.js 22.16+ or 24+ installed

## Setup

### Step 1: Create Dedicated Gmail Account

1. Go to https://accounts.google.com/signup
2. Create a new Google account for OpenClaw (e.g., `yourname-openclaw@gmail.com`)
3. Complete account setup and verify the email
4. Note the email address — this is OpenClaw's identity

> **Why a separate account?** This keeps the bot's access isolated. It can only
> read its own inbox, and only sees your calendar/Drive data that you explicitly
> share with it. If you ever want to revoke access, just un-share.

### Step 2: Create Google Cloud Project

The Google Cloud Project provides OAuth2 credentials so OpenClaw can use
Gmail, Calendar, and Drive APIs **as the dedicated bot account**.

1. Sign into https://console.cloud.google.com with the **dedicated Gmail account**
2. Create a new project (e.g., "OpenClaw")
3. Enable these APIs via APIs & Services > Library:
   - Gmail API
   - Google Calendar API
   - Google Drive API
4. Go to APIs & Services > Credentials
5. Configure the OAuth consent screen:
   - User type: External (select Internal if using Google Workspace)
   - App name: OpenClaw
   - Add your dedicated Gmail as a test user
6. Create OAuth 2.0 credentials:
   - Application type: Web application
   - Authorized redirect URIs: `http://localhost:3000/oauth2callback`
   (used only once to generate the refresh token)
7. Note the Client ID and Client Secret
8. Generate a refresh token:
   - Use the [OAuth 2.0 Playground](https://developers.google.com/oauthplayground)
   - Or use a local script to complete the OAuth flow
   - Scopes needed:
     - `https://www.googleapis.com/auth/gmail.modify` — read, send, and label emails in the bot's inbox
     - `https://www.googleapis.com/auth/calendar` — read/write events on calendars shared with the bot
     - `https://www.googleapis.com/auth/drive` — read/write files in folders shared with the bot
   - Note the refresh token

> **These scopes apply to the bot's own account**, not yours. `gmail.modify`
> lets the bot manage *its own* inbox. `calendar` and `drive` let it access
> calendars and folders that have been explicitly shared with it (Steps 3-4).

### Step 3: Share Your Calendar with OpenClaw

1. In your **personal** Google Calendar, go to Settings > [Calendar Name]
2. Under "Share with specific people", add the OpenClaw Gmail address
3. Permission: "Make changes to events" (so OpenClaw can create reminders on your behalf)

> This is the same sharing mechanism you'd use with a human assistant.
> OpenClaw can only see this calendar — not your other calendars, contacts,
> or account data.

### Step 4: Create a Shared Google Drive Folder

1. In your **personal** Google Drive, create a folder for OpenClaw (e.g., "OpenClaw Shared")
2. Right-click the folder > Share > add the OpenClaw Gmail address
3. Permission: "Editor" (so OpenClaw can create documents and share back)

> Only this specific folder (and its contents) will be visible to OpenClaw.
> It cannot see anything else in your Drive. You can drop files into this
> folder for OpenClaw to read, and it will create documents here for you.

### Step 5: Create Telegram Bot

1. Open Telegram and message @BotFather
2. Send `/newbot`
3. Choose a name (e.g., "OpenClaw Assistant")
4. Choose a username (e.g., `yourname_openclaw_bot`)
5. Note the bot token BotFather gives you

### Step 6: Create Anthropic API Key

1. Go to https://console.anthropic.com
2. Create a new API key
3. Note the key (starts with `sk-ant-`)

### Step 7: Create Notion Integration

1. Go to https://www.notion.so/my-integrations
2. Click "New integration"
3. Name: OpenClaw
4. Associated workspace: your personal workspace
5. Capabilities: Read content, Update content, Insert content
6. Note the integration token (starts with `ntn_`)
7. Go to your Personal Board in Notion
8. Click ••• > Connections > Connect to OpenClaw
9. This grants the integration access to only this board

### Step 8: Create Railway Account and API Token

1. Go to https://railway.app and create an account
2. Go to Account Settings > Tokens
3. Create a new token with full access
4. Note the token

### Step 9: Push Repo to GitHub

1. Create a new GitHub repository (e.g., `openclaw`)
2. Push this repo:
   ```bash
   git remote add origin git@github.com:YOUR_USERNAME/openclaw.git
   git push -u origin main
   ```

### Step 10: Configure and Deploy

1. Copy the example tfvars:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```
2. Fill in all values in `terraform/terraform.tfvars` with the credentials
   from the previous steps
3. Update `openclaw.json`:
   - Set `gateway.auth.token` to a secure random token (`openssl rand -hex 32`)
   - Set `gateway.controlUi.allowedOrigins` to your Railway service URL
   - Set `channels.telegram.allowFrom` to your Telegram user ID
4. Update `workspace/IDENTITY.md` with your bot's Gmail and Telegram username
5. Update `workspace/HEARTBEAT.md` and `workspace/AGENTS.md` with your Notion board ID
6. Deploy:
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

### Step 11: Verify Deployment

1. Open the service URL in your browser — you should see the OpenClaw dashboard
2. Enter your gateway token and connect
3. Complete the bootstrap/onboarding flow
4. Send a test message via the Control UI
5. Send a message to your Telegram bot and approve the pairing
6. Verify the heartbeat fires after 30 minutes

## Railway CLI

Install the [Railway CLI](https://docs.railway.com/guides/cli) and [OpenClaw CLI](https://www.npmjs.com/package/openclaw):

```bash
brew install railway
npm install -g openclaw
```

Configure your local CLI to talk to the remote gateway:

```bash
openclaw config set gateway.remote.url wss://YOUR_RAILWAY_URL.up.railway.app
openclaw config set gateway.remote.token YOUR_GATEWAY_TOKEN
```

Then manage devices and pairing:

```bash
openclaw devices list --url wss://YOUR_RAILWAY_URL.up.railway.app --token YOUR_GATEWAY_TOKEN
openclaw devices approve <device-id> --url wss://YOUR_RAILWAY_URL.up.railway.app --token YOUR_GATEWAY_TOKEN
```

## Configuration

- `openclaw.json` — Gateway configuration (auth, models, heartbeat)
- `workspace/SOUL.md` — Agent personality and boundaries
- `workspace/HEARTBEAT.md` — Periodic check-in tasks
- `workspace/IDENTITY.md` — Agent identity metadata
- `workspace/AGENTS.md` — Operating instructions

Config changes via git push apply on the next deploy. Config changes via the
Control UI persist across redeploys (unless git changes the same key).

## Customizing the Agent

The files in `workspace/` define who your agent is and how it behaves. You
should edit these to fit your own use case.

### `IDENTITY.md`

This is the agent's self-knowledge — its name, accounts, and how to refer to
itself. Update this with your bot's actual Gmail address and Telegram username.
You can also change the name and emoji if "OpenClaw" and 🦀 aren't your style.

### `SOUL.md`

This is the agent's personality, boundaries, and responsibilities. The defaults
are tuned for a household admin / email triage assistant, but you can reshape
this entirely. Some ideas:

- **Work assistant:** Focus on Slack triage, meeting prep, and project tracking
- **Research assistant:** Summarize articles, track topics, maintain a reading list
- **Finance tracker:** Monitor bills, flag unusual charges, summarize spending

The key sections to customize:
- **Personality** — How should it communicate? Terse or conversational? Proactive or wait-for-instructions?
- **Boundaries** — What should it do freely vs. ask about first?
- **Responsibilities** — What are its core jobs?

### `HEARTBEAT.md`

Defines what the agent checks on each periodic cycle (default: every 30 minutes).
Rewrite this to match your SOUL — if your agent is a research assistant, the
heartbeat might check RSS feeds instead of email.

### `AGENTS.md`

Operating rules for how the agent handles sessions, memory, integrations, and
external actions. The "Do freely / Ask first / Do carefully" framework is worth
keeping, but adjust the specific rules to match your integrations and comfort
level.

## Cost

~$10-20/month (Railway ~$5, Anthropic API ~$5-15 depending on usage).

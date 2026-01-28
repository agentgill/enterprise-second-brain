# The Enterprise Second Brain 🧠

A frictionless "second brain" pipeline that captures insights from Slack and stores them in Salesforce using AI classification.

1. 💬 Post a message to a private Slack channel
2. 🤖 Claude classifies it (People, Projects, Ideas, or Admin)
3. ☁️ It's automatically committed to Salesforce

No tagging. No deciding where things go. No friction.

Inspired by Nate Channel's approach using Zapier, adapted for enterprise environments using Slack, Workato, Claude, and Salesforce.

Full Post on Medium -- including Step-by-Step 

## Developer Fast Track 🚀

### Prerequisites 📋

- Node.js 20+, Python 3.11+, Salesforce CLI, Workato Platform CLI
- [UV](https://docs.astral.sh/uv/getting-started/installation/) (Fast Replacement for pip)
- [Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm)
- [Workato Developer Sandbox](https://www.workato.com/sandbox) (Free Developer sandbox)
- [Salesforce Developer Org](https://developer.salesforce.com/signup) (Free Developer Edition)
- [Slack](https://slack.com/get-started?entry_point=nav_menu#/createnew) (Create a free new slack just for this)
- [Get an Anthropic API Key](https://platform.claude.com/settings/keys) ($5 Credit when you first sign up)

Assumptions: UV is installed, Salesforce CLI is installed.

1. Free Workato Developer Sandbox
2. Free Salesforce Developer Org
3. Free Slack Workspace dedicated for Enterprise Second Brain
4. Have created Anthropic API Key

### Clone Repo

```bash
git clone https://github.com/agentgill/enterprise-second-brain.git
cd enterprise-second-brain
```

### Deploy Salesforce Metadata

1. Authenticate to your Salesforce Developer Org `sf org login web -a esb-dev`
2. Deploy metadata `sf project deploy start -d salesforce/force-app -o esb-dev`
3. Assign permission set `sf org assign permset -n Second_Brain_Access -o esb-dev`

### Setup Workato Platform CLI

Install Workato Platform CLI using UV

```bash
uv sync --python 3.12
```

> **Note:** We use [UV](https://docs.astral.sh/uv/) instead of pip for faster dependency management. The `uv run` prefix automatically executes commands within the virtual environment without needing to activate it.

### Configure Workato API Token

1. Log in to your Workato Sandbox `https://app.trial.workato.com`
2. Navigate to `Workspace admin` > `API clients`
3. Create a new `Client role` for simplicity when in Developer sandbox, just select all breaking the least privilege principle
4. Create a new `API client` Select Client role from above and save changes
5. Copy the API token somewhere so you can copy/paste when setting up Workato Platform CLI

### Configure Workato Platform CLI

1. Activate venv & Workato Init `uv run workato init`
2. Create a new profile `esb`
3. Select Workato region Developer Sandbox `https://app.trial.workato.com`
4. Copy/paste token generated from `Configure Workato API Token`
5. Create a new project called `src`

### Deploy Workato Source

As we intend to install the source in a new Workato Developer Sandbox, we need
copy the source to our new folder `src` before we can push into the workspace

1. Copy workato source `cp -r workato/* src/` and powershell `Copy-Item -Path workato\* -Destination src -Recurse`
2. Deploy workato src `uv run workato push`

### Update Workato Connections

1. Login into your Workato Developer Sandbox
2. Login into Slack Workspace (the one you signed up for, not your work one)
3. Navigate to connections for project
4. Then **Projects** -> **src** -> **esb** -> **connections**
5. Connect Slack - Allow the ‘Workato Trial’ app to access Slack
6. Connect Salesforce - Login to your Salesforce Developer Org & Allow App
7. Connect Anthropic - Update Anthropic API Key with your Key

### Create & Configure Slack App

Only do this after you have connected your apps

1. Create a new app `https://docs.slack.dev/app-management/quickstart-app-settings`
2. Create an app `From a manifest`
3. Pick a workspace to develop your app in - should be your new Slack workspace (not your work one)
4. Open `slack/manifest.json` and copy into `Create app from Manifest`
5. To get the `Request URL` from the `Ingress` Recipe
6. Click `New event in Slack` and copy the `Request URL` 
7. Replace `UPDATE_HERE` with the `Request URL`, then next
8. Click `Create` on the Review summary & create your app
9. Within the `Slack App > Features > Event Subscriptions` click `Retry` on the Request URL and `Save Changes`
10. Within the `Slack App > Settings > Install App`
11. Click `Install to YOUR_WORKSPACE_NAME`
12. Allow `Allow the ‘App Name’ app to access Slack`
13. View app(s) via here `https://api.slack.com/apps`

### Activate Recipes

Start all recipes `uv run workato recipes start --all`

## Project Structure 📁

```
├── salesforce/          # Salesforce metadata (Second_Brain__c object)
├── workato/             # Workato recipes and connections
├── slack/               # Slack app manifest
├── docs/                # Reference documentation
├── .claude/             # Claude Code skills and commands
└── src/                 # Your local Workato project (created during setup)
```

## Bonus Content 🎁

We've included some extras for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) users:

- **Claude Skills** - Custom skills for Salesforce admin and Workato development (`.claude/skills/`)
- **Claude Commands** - Deploy Salesforce metadata with `/deploy-salesforce` (`.claude/commands/`)
- **Salesforce Plan** - Reference implementation plan (`docs/salesforce-plan.md`)

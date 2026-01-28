---
name: workato-developer
description: Workato developer using Platform CLI. Use when working with Workato locally.
Triggers on tasks involving Workato Platform CLI commands; General Recipe Lifecycle Management Q&A;
Managing recipe, connection, and lookup_table local JSON structures.
---

# Workato Platform CLI Developer Guide

## Overview

The Workato Platform CLI is a modern, type-safe command-line interface for the Workato API. It enables developers to build, validate, and manage Workato recipes, connections, and projects locally with version control integration.

## System Requirements

- Python 3.12 or later
- uv package manager (preferred over pip)
- Valid Workato account with API token
- Network access to Workato API endpoints
- Recommended: Git for version control

## Installation

```bash
uv add workato-platform-cli
workato --version
```

**Note:** Always ensure the virtual environment is activated before running CLI commands:
```bash
source ~/.zshrc
```

## Authentication Setup

### 1. Create a Client Role

Navigate to **Workspace admin > API clients > Client roles** and create a role with these permissions:

**Projects tab (all selected):**
- Projects & folders
- Connections
- Recipes
- Recipe versions
- Lifecycle management
- Export manifests

**Tools tab:**
- Collections & endpoints operations (list, create, enable/disable)

**Admin tab:**
- Workspace details (all selected)

### 2. Create an API Client

1. Go to **Workspace admin > API clients**
2. Select **Create API client**
3. Assign your client role
4. Configure environment and project access
5. Set allowed IPs if needed
6. **Copy and save your API token immediately** (begins with `wrk`, e.g., `wrkprod-...`)

### 3. Initialize the CLI

```bash
workato init
```

This guides you through:
1. Profile name (default or custom)
2. Data center region selection
3. API token entry
4. Project selection

Verify with:
```bash
workato workspace
```

## Environment Variables

- `WORKATO_PROFILE` - Active profile name
- `WORKATO_API_TOKEN` - API token for authentication
- `WORKATO_API_HOST` - API endpoint host

---

# CLI Command Reference

## Global Options

| Option | Description |
|--------|-------------|
| `--profile TEXT` | Specifies authentication profile |
| `--version` | Shows CLI version |
| `--help` | Displays available commands |
| `--output-format` | Output as table (default) or JSON |

## Pagination Options (where applicable)

| Option | Description |
|--------|-------------|
| `--page INTEGER` | Page number (min 1) |
| `--per-page INTEGER` | Results per page (max 100) |

---

## Initialization & Workspace

### workato init
Sets up authentication, region selection, and project configuration.

### workato workspace
Displays current workspace information and connection status.

### workato pull
Synchronizes recipes, connections, and data tables from workspace to local directory.

```bash
workato pull
```

### workato push
Uploads local modifications to workspace with optional recipe restart.

```bash
workato push
```

---

## Profile Management

### Local Profile Storage

Workato CLI profiles are stored in `~/.workato/profiles` as a JSON file:

```json
{
  "current_profile": "agent-workato-demo",
  "profiles": {
    "default": {
      "region": "trial",
      "region_url": "https://app.trial.workato.com",
      "workspace_id": 2100003058
    },
    "production": {
      "region": "us",
      "region_url": "https://app.workato.com",
      "workspace_id": 1234567890
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `current_profile` | Name of the active profile |
| `profiles` | Map of profile name to configuration |
| `region` | Data center region (trial, us, eu, jp, sg) |
| `region_url` | API endpoint URL |
| `workspace_id` | Workato workspace identifier |

### workato profiles list
Shows all configured authentication profiles.

### workato profiles use \<NAME\>
Switches active profile for subsequent operations.

```bash
workato profiles use production
```

### workato profiles status
Displays currently active profile with configuration details.

### workato profiles delete \<NAME\>
Removes a profile from configuration.

---

## Project Management

### workato projects list
Enumerates available projects in workspace.

### workato projects use \<NAME\>
Changes active project context.

```bash
workato projects use "Enterprise Second Brain"
```

---

## Recipe Operations

### workato recipes list
Lists recipes with filtering options.

```bash
workato recipes list
workato recipes list --folder "subfolder"
workato recipes list --status running
```

### workato recipes validate --path \<FILE\>
Checks JSON syntax and schema compliance locally.

```bash
workato recipes validate --path ./recipes/my_recipe.recipe.json
```

### workato recipes start
Enables stopped recipes by ID or name.

```bash
workato recipes start --name "My Recipe"
workato recipes start --id 12345
```

### workato recipes stop
Halts running recipes by ID or name.

```bash
workato recipes stop --name "My Recipe"
```

### workato recipes update-connection
Modifies connector credentials in stopped recipes.

### workato recipes jobs
Shows recipe execution history.

```bash
workato recipes jobs --name "My Recipe"
```

---

## Connection Management

### workato connections list
Shows all connections with provider filtering.

```bash
workato connections list
workato connections list --provider slack
```

### workato connections create
Establishes new connections with authentication details.

### workato connections create-oauth
Initiates OAuth authentication flow.

### workato connections get-oauth-url
Generates OAuth authorization URL.

### workato connections update
Modifies connection properties.

### workato connections pick-list
Retrieves dynamic field values from connections.

---

## Connector Information

### workato connectors list
Displays available standard and custom connectors.

### workato connectors parameters
Shows authentication requirements and configuration fields.

---

## Data Tables & Properties

### workato data-tables list
Enumerates data tables with schema information.

### workato data-tables create
Creates structured data storage with defined schema.

### workato properties list
Lists environment or project-level configuration variables.

### workato properties upsert
Creates or updates configuration properties.

```bash
workato properties upsert --file properties.json
```

---

## API Management

### workato api-collections list
Shows recipe endpoint groupings.

### workato api-collections create
Establishes new endpoint collections.

### workato api-collections list-endpoints
Displays endpoints within a collection.

### workato api-collections enable-endpoint
Activates specific API endpoints.

### workato api-clients list
Shows programmatic access clients.

### workato api-clients create
Establishes new API clients with credentials.

---

## Documentation & Assets

### workato guide topics
Lists available help documentation sections.

### workato guide search \<QUERY\>
Searches documentation by keywords.

### workato guide content \<TOPIC\>
Displays full documentation for specific topics.

### workato assets
Comprehensive listing of all workspace assets with types and locations.

---

# Local JSON File Structures

## Recipe JSON Structure (*.recipe.json)

Recipe files define automation workflows with triggers, actions, and logic.

```json
{
  "name": "Recipe Name",
  "description": "Recipe description",
  "version": 1,
  "private": false,
  "concurrency": 1,
  "code": {
    "number": 0,
    "provider": "connector_name",
    "name": "trigger_or_action_name",
    "as": "unique_step_id",
    "keyword": "trigger",
    "input": { },
    "block": [ ]
  },
  "config": [ ]
}
```

### Top-Level Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Display name of the recipe |
| `description` | string | Recipe description |
| `version` | integer | Recipe version number |
| `private` | boolean | Whether recipe is private |
| `concurrency` | integer | Max concurrent executions |
| `code` | object | Recipe logic (trigger + steps) |
| `config` | array | Connection configurations |

### Code Block Structure

Each step in a recipe follows this structure:

```json
{
  "number": 0,
  "provider": "slack",
  "name": "new_event",
  "as": "91503a3a",
  "keyword": "trigger",
  "input": { },
  "filter": { },
  "block": [ ],
  "extended_input_schema": [ ],
  "extended_output_schema": [ ],
  "uuid": "unique-uuid"
}
```

### Step Keywords

| Keyword | Description |
|---------|-------------|
| `trigger` | Recipe trigger (entry point) |
| `action` | Connector action |
| `if` | Conditional branch |
| `try` | Error handling block |
| `catch` | Error catch block |
| `stop` | Stop recipe execution |

### Data Pills (Dynamic Values)

Data pills reference output from previous steps using the `_dp()` function:

```json
"#{_dp('{\"pill_type\":\"output\",\"provider\":\"slack\",\"line\":\"91503a3a\",\"path\":[\"event\",\"text\"]}')}"
```

Components:
- `pill_type`: Always "output"
- `provider`: Connector name
- `line`: Step ID (`as` value)
- `path`: Array path to the field

### Formula Mode

Prefix with `=` for formula mode (Ruby expressions):

```json
"message": "=\"Hello \" + _dp('{...}')"
```

### Filter/Condition Structure

```json
{
  "filter": {
    "conditions": [
      {
        "operand": "equals_to",
        "lhs": "#{_dp('...')}",
        "rhs": "value",
        "uuid": "condition-uuid"
      }
    ],
    "operand": "and",
    "type": "compound"
  }
}
```

Operand types: `equals_to`, `present`, `not_equals_to`, `contains`, `starts_with`, `ends_with`, `greater_than`, `less_than`

### Recipe Function (Callable Recipe)

Trigger for callable recipes:

```json
{
  "provider": "workato_recipe_function",
  "name": "execute",
  "keyword": "trigger",
  "input": {
    "parameters_schema_json": "[{\"control_type\":\"text\",\"label\":\"Message\",\"type\":\"string\",\"name\":\"message\"}]",
    "result_schema_json": "[{\"name\":\"result\",\"type\":\"string\"}]"
  }
}
```

### Calling Another Recipe

```json
{
  "provider": "workato_recipe_function",
  "name": "call_recipe",
  "keyword": "action",
  "input": {
    "flow_id": {
      "zip_name": "other_recipe.recipe.json",
      "name": "Other Recipe",
      "folder": ""
    },
    "parameters": {
      "param1": "value"
    }
  }
}
```

### Return Result

```json
{
  "provider": "workato_recipe_function",
  "name": "return_result",
  "keyword": "action",
  "input": {
    "result": {
      "field1": "#{_dp('...')}"
    }
  }
}
```

### Config Section

Defines connections used by the recipe:

```json
{
  "config": [
    {
      "keyword": "application",
      "provider": "slack",
      "skip_validation": false,
      "account_id": {
        "zip_name": "myslackworkspace.connection.json",
        "name": "MySlackWorkspace",
        "folder": ""
      }
    },
    {
      "keyword": "application",
      "provider": "logger",
      "skip_validation": false,
      "account_id": null
    }
  ]
}
```

For custom connectors:
```json
{
  "account_id": {
    "zip_name": "myconnection.connection.json",
    "name": "MyConnection",
    "folder": "",
    "custom": true
  }
}
```

---

## Connection JSON Structure (*.connection.json)

Connection files define authentication to external services.

```json
{
  "name": "MySlackWorkspace",
  "provider": "slack",
  "root_folder": false
}
```

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Connection display name |
| `provider` | string | Connector identifier |
| `root_folder` | boolean | Whether in root folder |

Note: Actual credentials are not stored in JSON files for security. OAuth connections are managed via CLI commands.

---

## Lookup Table Reference

Lookup tables are referenced in recipes with this structure:

```json
{
  "provider": "lookup_table",
  "name": "get_entry",
  "input": {
    "lookup_table_id": {
      "zip_name": "my_table.lookup_table.json",
      "name": "my_table",
      "folder": ""
    },
    "parameters": {
      "col1": "search_value"
    }
  }
}
```

Actions: `get_entry`, `add_entry`, `update_entry`, `delete_entry`

---

## Schema Definition Structure

Used in `extended_input_schema` and `extended_output_schema`:

```json
{
  "control_type": "text",
  "label": "Field Label",
  "name": "field_name",
  "type": "string",
  "optional": false,
  "hint": "Help text",
  "sticky": true
}
```

### Control Types

| Type | Description |
|------|-------------|
| `text` | Single-line text input |
| `text-area` | Multi-line text input |
| `number` | Numeric input |
| `integer` | Integer input |
| `select` | Dropdown selection |
| `switch` | Boolean toggle |
| `schema-designer` | Dynamic schema builder |

### Field Types

| Type | Description |
|------|-------------|
| `string` | Text value |
| `integer` | Integer number |
| `number` | Decimal number |
| `boolean` | True/false |
| `object` | Nested object with `properties` |
| `array` | List with `of` or `properties` |
| `date` | Date value |
| `date_time` | DateTime value |

---

## Common Providers

| Provider | Description |
|----------|-------------|
| `slack` | Slack integration |
| `salesforce` | Salesforce CRM |
| `logger` | Workato logging |
| `lookup_table` | Lookup table operations |
| `workato_recipe_function` | Callable recipes |
| `variables` | Recipe variables |
| `http` | HTTP requests |

---

# Development Workflow

## Typical Workflow

1. **Initialize**: `workato init`
2. **Pull**: `workato pull` to get current state
3. **Edit**: Modify recipe JSON files locally
4. **Validate**: `workato recipes validate --path <file>`
5. **Push**: `workato push` to deploy changes
6. **Monitor**: `workato recipes jobs` to check executions

## Best Practices

### Project Organization
- Group recipes by business function
- Use descriptive connection names
- Implement consistent tagging
- Conduct regular maintenance reviews

### Version Control
- Commit after each logical change
- Use meaningful commit messages
- Review diffs before pushing

### Multi-Environment
- Use separate profiles per environment
- `workato profiles use dev`
- `workato profiles use production`

---

# Troubleshooting

## Python Version Error
```
"Python 3.12+ required"
```
Update Python and verify: `python --version`

## Command Not Found
```bash
uv show workato-platform-cli
python -m workato_platform.cli.main --help
```

## API Credentials Error
```
"Could not resolve API credentials"
```
Run `workato init` and enter your API token.

## Validation Errors
Check JSON syntax and ensure all referenced connections exist.

---

# Quick Reference

```bash
# Setup
uv add workato-platform-cli
workato init
workato workspace

# Daily workflow
workato pull
# ... edit files ...
workato recipes validate --path ./recipe.recipe.json
workato push

# Management
workato recipes list
workato recipes start --name "Recipe Name"
workato recipes stop --name "Recipe Name"
workato connections list
workato profiles use production
```

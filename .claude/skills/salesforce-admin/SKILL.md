---
name: salesforce-admin
description: Salesforce administration using Salesforce CLI (sf/sfdx). Use when working with Salesforce metadata, custom objects, fields, users, profiles, permission sets, Flows, automation, or data management. Triggers on tasks involving sf/sfdx commands, Salesforce Setup configuration, metadata deployment, user security administration, or Salesforce data operations.
---

# Salesforce Admin

Salesforce administration via CLI with best practices for metadata management, security, automation, and data operations.

## Quick Reference

### Common sf CLI Commands

```bash
# Authentication
sf org login web --alias myorg              # Login via browser
sf org login web --alias myorg --instance-url https://test.salesforce.com  # Sandbox
sf org list                                  # List connected orgs
sf org display --target-org myorg           # Show org details

# Metadata Operations
sf project retrieve start --metadata "CustomObject:Account"    # Retrieve specific
sf project retrieve start --manifest manifest/package.xml      # Retrieve from manifest
sf project deploy start --source-dir force-app                 # Deploy directory
sf project deploy start --metadata "CustomField:Account.Custom__c"  # Deploy specific

# Data Operations
sf data query --query "SELECT Id, Name FROM Account LIMIT 10" --target-org myorg
sf data export tree --query "SELECT Id, Name FROM Account" --output-dir data/
sf data import tree --files data/Account.json --target-org myorg

# User Management
sf org assign permset --name MyPermSet --target-org myorg
sf org generate password --target-org myorg
```

## Workflow Decision Tree

1. **Creating/modifying metadata** → Use `sf project retrieve` then edit XML, then `sf project deploy`
2. **User/security changes** → See [references/security.md](references/security.md)
3. **Building automation** → See [references/automation.md](references/automation.md)
4. **Data operations** → See [references/data-management.md](references/data-management.md)
5. **Object/field work** → See [references/objects-fields.md](references/objects-fields.md)

## Project Structure

Standard Salesforce DX project layout:

```
force-app/
└── main/
    └── default/
        ├── classes/           # Apex classes
        ├── objects/           # Custom objects and fields
        │   └── MyObject__c/
        │       ├── MyObject__c.object-meta.xml
        │       └── fields/
        │           └── MyField__c.field-meta.xml
        ├── flows/             # Flow definitions
        ├── permissionsets/    # Permission sets
        ├── profiles/          # Profiles
        ├── triggers/          # Apex triggers
        └── layouts/           # Page layouts
manifest/
└── package.xml               # Deployment manifest
```

## Naming Conventions (Best Practices)

| Type | Convention | Example |
|------|------------|---------|
| Custom Object | PascalCase + `__c` | `Invoice__c`, `OrderItem__c` |
| Custom Field | PascalCase + `__c` | `Total_Amount__c`, `Is_Active__c` |
| Flow | PascalCase, descriptive | `Account_After_Insert_Handler` |
| Permission Set | PascalCase, role-based | `Sales_Manager_Access` |
| Apex Class | PascalCase | `AccountTriggerHandler` |
| Apex Trigger | Object + Trigger | `AccountTrigger` |

## Common Tasks

### Create a Custom Object

1. Retrieve existing objects for reference:
   ```bash
   sf project retrieve start --metadata "CustomObject"
   ```

2. Create object metadata XML at `force-app/main/default/objects/MyObject__c/MyObject__c.object-meta.xml`

3. Deploy:
   ```bash
   sf project deploy start --source-dir force-app/main/default/objects/MyObject__c
   ```

### Add a Custom Field

1. Create field XML at `force-app/main/default/objects/Account/fields/My_Field__c.field-meta.xml`

2. Deploy:
   ```bash
   sf project deploy start --metadata "CustomField:Account.My_Field__c"
   ```

### Deploy with Validation Only (Checkonly)

```bash
sf project deploy start --source-dir force-app --dry-run --test-level RunLocalTests
```

### Run Apex Tests

```bash
sf apex run test --target-org myorg --test-level RunLocalTests --wait 10
sf apex run test --class-names MyTestClass --target-org myorg
```

## Resources

- [references/objects-fields.md](references/objects-fields.md) - Object/field metadata templates and patterns
- [references/security.md](references/security.md) - Profiles, permission sets, sharing rules
- [references/automation.md](references/automation.md) - Flows, Process Builder migration, approval processes
- [references/data-management.md](references/data-management.md) - Import/export, deduplication, data quality

# Implementation Plan: Second Brain Custom Object

## Overview
Create a Salesforce custom object called "Second Brain" with four fields (Confidence, Category, Message, Due Date) and a custom tab following enterprise best practices and project conventions.

## Object Specifications

**API Name:** `Second_Brain__c`
- Label: "Second Brain"
- Plural Label: "Second Brains"
- Name Field: Auto-number format `SB-{0000}` (e.g., SB-0001, SB-0002)
- Sharing Model: ReadWrite (collaborative access)

## Field Specifications

### 1. Confidence__c (Picklist)
- **Values:** Low, Medium, High
- **Default:** Medium
- **Required:** No
- **History Tracking:** Yes

### 2. Category__c (Picklist)
- **Values:** People, Projects, Ideas, Admin, Other
- **Default:** None (forces conscious selection)
- **Required:** No
- **History Tracking:** Yes

### 3. Message__c (Long Text Area)
- **Length:** 32,768 characters
- **Visible Lines:** 6
- **Required:** No
- **History Tracking:** No (avoid bloating history tables)

### 4. Due_Date__c (Date)
- **Type:** Date
- **Required:** No
- **History Tracking:** Yes
- **Description:** Optional due date for time-sensitive entries

## File Structure

All files will be created under `vendors/salesforce/force-app/main/default/`:

```
objects/
└── Second_Brain__c/
    ├── Second_Brain__c.object-meta.xml
    └── fields/
        ├── Confidence__c.field-meta.xml
        ├── Category__c.field-meta.xml
        ├── Message__c.field-meta.xml
        └── Due_Date__c.field-meta.xml

layouts/
└── Second_Brain__c-Second Brain Layout.layout-meta.xml

tabs/
└── Second_Brain__c.tab-meta.xml

permissionsets/
└── Second_Brain_Access.permissionset-meta.xml
```

## Critical Files to Create

1. **Second_Brain__c.object-meta.xml** - Core object definition with auto-number name field, ReadWrite sharing model, enabled features (Activities, History, Reports, Search)

2. **Confidence__c.field-meta.xml** - Picklist with Low/Medium/High values, Medium as default

3. **Category__c.field-meta.xml** - Picklist with People/Projects/Ideas/Admin/Other values, no default

4. **Message__c.field-meta.xml** - Long text area (32,768 chars, 6 visible lines)

5. **Due_Date__c.field-meta.xml** - Date field for optional due dates

6. **Second_Brain__c-Second Brain Layout.layout-meta.xml** - Three sections: Information (Name, Category, Confidence, Due Date, Owner), Message (full width), System Information (Created By, Last Modified By)

7. **Second_Brain__c.tab-meta.xml** - Custom tab with icon (Custom20-Brain or similar), default visibility

8. **Second_Brain_Access.permissionset-meta.xml** - CRUD permissions, field-level security, tab visibility

## Implementation Steps

### 1. Create Directory Structure
```bash
cd salesforce/force-app/main/default
mkdir -p objects/Second_Brain__c/fields
mkdir -p layouts
mkdir -p tabs
mkdir -p permissionsets
```

### 2. Create XML Metadata Files
Create each of the 8 files listed above with proper XML structure following Salesforce Metadata API v64.0 specifications.

### 3. Deploy to Salesforce
```bash
cd salesforce

# Deploy object and fields
sf project deploy start \
  --source-dir force-app/main/default/objects/Second_Brain__c \
  --target-org <org-alias>

# Deploy layout
sf project deploy start \
  --source-dir force-app/main/default/layouts \
  --target-org <org-alias>

# Deploy tab
sf project deploy start \
  --source-dir force-app/main/default/tabs \
  --target-org <org-alias>

# Deploy permission set
sf project deploy start \
  --source-dir force-app/main/default/permissionsets/Second_Brain_Access.permissionset-meta.xml \
  --target-org <org-alias>
```

### 4. Assign Permission Set
```bash
sf org assign permset --name Second_Brain_Access --target-org <org-alias>
```

## Verification Steps

### 1. Verify Object Creation
```bash
sf data query \
  --query "SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName = 'Second_Brain__c'" \
  --target-org <org-alias>
```

### 2. Verify Fields
```bash
sf data query \
  --query "SELECT QualifiedApiName, DataType FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'Second_Brain__c'" \
  --target-org <org-alias>
```

### 3. Create Test Record
```bash
sf data create record --sobject Second_Brain__c \
  --values "Category__c=Ideas Confidence__c=High Message__c='Test entry from CLI' Due_Date__c=2025-12-31" \
  --target-org <org-alias>
```

### 4. Query Test Records
```bash
sf data query \
  --query "SELECT Id, Name, Category__c, Confidence__c, Due_Date__c, Message__c FROM Second_Brain__c LIMIT 5" \
  --target-org <org-alias>
```

### 5. Manual UI Testing
1. Login to Salesforce org
2. Open App Launcher and search for "Second Brain" (should appear as a tab)
3. Click the Second Brain tab to view list
4. Click "New" to create a record
5. Verify Name field is auto-populated (readonly)
6. Select Category and Confidence values from picklists
7. Set a Due Date using the date picker
8. Enter message text
9. Save and verify record appears with auto-number (SB-0001, etc.)

### 6. Test Search & Reports
- Use Global Search to find Second Brain records
- Create a new report and verify "Second Brains" appears as a report type

## Design Rationale

**Auto-number Name Field:** Provides unique identifiers without user input, ensures no duplicate names

**ReadWrite Sharing Model:** Enables collaboration - users can create/edit their own records and read others' records

**Optional Fields:** Maximum flexibility for users - only Name is system-generated and readonly

**History Tracking:** Enabled for Confidence and Category to track changes over time, disabled for Message to avoid storage bloat

**Medium as Default Confidence:** Balanced starting point between Low and High

**No Default Category:** Forces conscious categorization to maintain data quality

**32K Character Message:** Sufficient for detailed notes while balancing storage efficiency (max possible is 131K)

**Due Date Field:** Optional date field enables time-sensitive tracking without forcing all entries to have deadlines

**Custom Tab:** Provides direct navigation to Second Brain records from App Launcher and navigation bar

**Permission Set Approach:** Modern Salesforce best practice over profile modifications, allows flexible additive permissions

## Future Enhancement Options

1. **Validation Rules:** Require Message when Confidence is High
2. **Search Layouts:** Customize global search results display
3. **List Views:** Pre-built views like "High Confidence Ideas" or "Project Items"
4. **Quick Actions:** "New Idea" button with pre-populated Category
5. **Record Types:** Different layouts/workflows per category
6. **Compact Layout:** Optimize mobile and highlights panel display
7. **Related Lists:** Link to Accounts, Contacts, or Opportunities
8. **Chatter Integration:** Enable feed for collaboration
9. **Workato Integration:** Sync with external systems

## Rollback Plan

If needed, delete in this order:
1. Permission set: `Second_Brain_Access`
2. Tab: `Second_Brain__c`
3. Layout: `Second_Brain__c-Second Brain Layout`
4. Object: `Second_Brain__c` (cascades to delete fields automatically)

Use Salesforce CLI destructive changes or manual deletion from Setup.

## Critical Files Reference

**From exploration:**
- `/Users/mikegill/Gill Dropbox/Mike Gill/workspaces/workato/enteprise-second-brain/vendors/salesforce/sfdx-project.json` - Project config with API v64.0
- `/Users/mikegill/Gill Dropbox/Mike Gill/workspaces/workato/enteprise-second-brain/.claude/skills/salesforce-admin/references/objects-fields.md` - Template patterns

**To be created:**
- All metadata XML files listed in File Structure section above

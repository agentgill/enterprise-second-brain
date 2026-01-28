# Data Management Reference

## Data Export

### SOQL Query Export
```bash
# Query and display
sf data query --query "SELECT Id, Name, Industry FROM Account WHERE Industry != null LIMIT 100" --target-org myorg

# Export to CSV
sf data query --query "SELECT Id, Name, Industry FROM Account" --target-org myorg --result-format csv > accounts.csv

# Export to JSON
sf data query --query "SELECT Id, Name, Industry FROM Account" --target-org myorg --result-format json > accounts.json
```

### Tree Export (Preserves Relationships)
```bash
# Export Account with related Contacts
sf data export tree --query "SELECT Id, Name, (SELECT Id, FirstName, LastName, Email FROM Contacts) FROM Account WHERE Id = '001XXXXXXXXXXXX'" --output-dir ./data --target-org myorg

# Export with plan file for reimport
sf data export tree --query "SELECT Id, Name FROM Account LIMIT 10" --output-dir ./data --plan --target-org myorg
```

### Bulk Export
```bash
# Large dataset export using Bulk API
sf data export bulk --query "SELECT Id, Name, Industry FROM Account" --output-file accounts.csv --target-org myorg
```

## Data Import

### Tree Import
```bash
# Import from exported JSON
sf data import tree --files data/Account.json --target-org myorg

# Import using plan file (handles relationships)
sf data import tree --plan data/Account-plan.json --target-org myorg
```

### Bulk Upsert
```bash
# Upsert records using external ID
sf data upsert bulk --sobject Account --file accounts.csv --external-id External_Id__c --target-org myorg

# Wait for completion
sf data upsert bulk --sobject Account --file accounts.csv --external-id External_Id__c --wait 10 --target-org myorg
```

### Single Record Operations
```bash
# Create single record
sf data create record --sobject Account --values "Name='Test Account' Industry='Technology'" --target-org myorg

# Update single record
sf data update record --sobject Account --record-id 001XXXXXXXXXXXX --values "Industry='Healthcare'" --target-org myorg

# Delete single record
sf data delete record --sobject Account --record-id 001XXXXXXXXXXXX --target-org myorg
```

## Bulk API Operations

### Bulk Delete
```bash
# Delete records from CSV (must contain Id column)
sf data delete bulk --sobject Account --file accounts_to_delete.csv --target-org myorg
```

### Check Bulk Job Status
```bash
# List recent bulk jobs
sf data bulk results --job-id <job-id> --target-org myorg
```

## Data Quality

### Duplicate Rules Metadata
```xml
<?xml version="1.0" encoding="UTF-8"?>
<DuplicateRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Account.Standard_Account_Duplicate_Rule</fullName>
    <actionOnInsert>Allow</actionOnInsert>
    <actionOnUpdate>Allow</actionOnUpdate>
    <alertText>This account may be a duplicate.</alertText>
    <isActive>true</isActive>
    <operationsOnInsert>Alert</operationsOnInsert>
    <operationsOnUpdate>Alert</operationsOnUpdate>
    <duplicateRuleMatchRules>
        <matchRuleSObjectType>Account</matchRuleSObjectType>
        <matchingRule>Standard_Account_Match_Rule_v1_0</matchingRule>
    </duplicateRuleMatchRules>
</DuplicateRule>
```

### Matching Rules Metadata
```xml
<?xml version="1.0" encoding="UTF-8"?>
<MatchingRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Account.Account_Name_Match</fullName>
    <label>Account Name Match</label>
    <ruleStatus>Active</ruleStatus>
    <matchingRuleItems>
        <blankValueBehavior>NullNotAllowed</blankValueBehavior>
        <fieldName>Name</fieldName>
        <matchingMethod>Fuzzy</matchingMethod>
    </matchingRuleItems>
    <matchingRuleItems>
        <blankValueBehavior>NullNotAllowed</blankValueBehavior>
        <fieldName>BillingCity</fieldName>
        <matchingMethod>Exact</matchingMethod>
    </matchingRuleItems>
</MatchingRule>
```

## Validation Rules

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Account.Require_Industry_For_Enterprise</fullName>
    <active>true</active>
    <description>Require Industry field for Enterprise accounts</description>
    <errorConditionFormula>AND(
        ISPICKVAL(Type, 'Enterprise'),
        ISBLANK(Industry)
    )</errorConditionFormula>
    <errorMessage>Industry is required for Enterprise accounts.</errorMessage>
    <errorDisplayField>Industry</errorDisplayField>
</ValidationRule>
```

## Data Loader CLI Alternative

For large operations, use Salesforce CLI's bulk commands:

```bash
# Insert
sf data upsert bulk --sobject Contact --file contacts.csv --external-id Email --target-org myorg

# Update (requires Id column)
sf data upsert bulk --sobject Contact --file contacts.csv --external-id Id --target-org myorg

# Delete
sf data delete bulk --sobject Contact --file contacts_to_delete.csv --target-org myorg
```

## Common SOQL Patterns

### Query with Relationship
```sql
SELECT Id, Name, Account.Name, Account.Industry
FROM Contact
WHERE Account.Industry = 'Technology'
```

### Aggregate Query
```sql
SELECT Industry, COUNT(Id) total
FROM Account
GROUP BY Industry
HAVING COUNT(Id) > 5
```

### Date Filters
```sql
SELECT Id, Name, CreatedDate
FROM Account
WHERE CreatedDate = LAST_N_DAYS:30
```

```sql
SELECT Id, Name, CreatedDate
FROM Account
WHERE CreatedDate >= 2024-01-01T00:00:00Z
```

### Subquery (Child Records)
```sql
SELECT Id, Name, (SELECT Id, FirstName, LastName FROM Contacts)
FROM Account
WHERE Id = '001XXXXXXXXXXXX'
```

### Parent Query
```sql
SELECT Id, FirstName, LastName, Account.Name, Account.Industry
FROM Contact
WHERE Account.Industry IN ('Technology', 'Finance')
```

## Sandbox Data Operations

### Refresh Sandbox
Sandboxes are refreshed via Setup UI. After refresh:

```bash
# Re-authenticate to sandbox
sf org login web --alias mysandbox --instance-url https://test.salesforce.com

# Verify connection
sf org display --target-org mysandbox
```

### Anonymize Data Script Pattern

Use Anonymous Apex for data anonymization:
```bash
sf apex run --file scripts/anonymize_data.apex --target-org mysandbox
```

Example `anonymize_data.apex`:
```apex
List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 1000];
for (Contact c : contacts) {
    c.FirstName = 'Test';
    c.LastName = 'User' + c.Id;
    c.Email = c.Id + '@example.com';
}
update contacts;
```

## Data CLI Commands Summary

| Operation | Command |
|-----------|---------|
| Query | `sf data query --query "SELECT..." --target-org myorg` |
| Export CSV | `sf data query --query "SELECT..." --result-format csv > file.csv` |
| Export Tree | `sf data export tree --query "SELECT..." --output-dir ./data` |
| Import Tree | `sf data import tree --files data/Account.json` |
| Create Record | `sf data create record --sobject Account --values "Name='Test'"` |
| Update Record | `sf data update record --sobject Account --record-id 001XX --values "Name='New'"` |
| Delete Record | `sf data delete record --sobject Account --record-id 001XX` |
| Bulk Upsert | `sf data upsert bulk --sobject Account --file data.csv --external-id Id` |
| Bulk Delete | `sf data delete bulk --sobject Account --file ids.csv` |

## Best Practices

1. **Always backup before bulk operations** - Export data first
2. **Use external IDs for upserts** - Prevents duplicates
3. **Test in sandbox first** - Validate imports before production
4. **Batch large operations** - Stay within governor limits
5. **Use Bulk API for >200 records** - More efficient for large datasets
6. **Monitor API limits** - Check usage with `sf limits api display`
7. **Document data mappings** - Maintain field mapping documentation

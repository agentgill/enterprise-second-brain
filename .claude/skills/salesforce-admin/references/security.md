# Security Administration Reference

## Permission Set Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Sales Manager Access</label>
    <description>Permissions for Sales Managers</description>
    <hasActivationRequired>false</hasActivationRequired>
    <license>Salesforce</license>

    <!-- Object Permissions -->
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>false</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <object>Opportunity</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>

    <!-- Field Permissions -->
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Amount</field>
        <readable>true</readable>
    </fieldPermissions>

    <!-- User Permissions -->
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewAllData</name>
    </userPermissions>

    <!-- Tab Settings -->
    <tabSettings>
        <tab>standard-Opportunity</tab>
        <visibility>Visible</visibility>
    </tabSettings>

    <!-- Record Type Assignments -->
    <recordTypeVisibilities>
        <recordType>Opportunity.Standard</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>

    <!-- Application Visibility -->
    <applicationVisibilities>
        <application>standard__Sales</application>
        <visible>true</visible>
    </applicationVisibilities>
</PermissionSet>
```

## Permission Set Group Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSetGroup xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Sales Team Bundle</label>
    <description>Combined permissions for Sales team</description>
    <status>Active</status>
    <permissionSets>
        <permissionSet>Sales_Base_Access</permissionSet>
        <permissionSet>Opportunity_Edit</permissionSet>
        <permissionSet>Report_Builder</permissionSet>
    </permissionSets>
</PermissionSetGroup>
```

## Profile Metadata (Partial)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <custom>false</custom>
    <userLicense>Salesforce</userLicense>

    <!-- Login IP Ranges -->
    <loginIpRanges>
        <startAddress>0.0.0.0</startAddress>
        <endAddress>255.255.255.255</endAddress>
    </loginIpRanges>

    <!-- Login Hours -->
    <loginHours>
        <mondayStart>480</mondayStart>
        <mondayEnd>1080</mondayEnd>
        <!-- Values in minutes from midnight: 480 = 8am, 1080 = 6pm -->
    </loginHours>

    <!-- Object Permissions -->
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <object>Account</object>
        <viewAllRecords>false</viewAllRecords>
    </objectPermissions>
</Profile>
```

## Sharing Rule Template

### Criteria-Based Sharing Rule
```xml
<?xml version="1.0" encoding="UTF-8"?>
<SharingRules xmlns="http://soap.sforce.com/2006/04/metadata">
    <sharingCriteriaRules>
        <fullName>Share_High_Value_Accounts</fullName>
        <accessLevel>Read</accessLevel>
        <label>Share High Value Accounts</label>
        <sharedTo>
            <group>Sales_Team</group>
        </sharedTo>
        <criteriaItems>
            <field>AnnualRevenue</field>
            <operation>greaterThan</operation>
            <value>1000000</value>
        </criteriaItems>
    </sharingCriteriaRules>
</SharingRules>
```

### Owner-Based Sharing Rule
```xml
<?xml version="1.0" encoding="UTF-8"?>
<SharingRules xmlns="http://soap.sforce.com/2006/04/metadata">
    <sharingOwnerRules>
        <fullName>Share_Team_Accounts</fullName>
        <accessLevel>Edit</accessLevel>
        <label>Share Team Accounts</label>
        <sharedFrom>
            <group>West_Sales_Team</group>
        </sharedFrom>
        <sharedTo>
            <group>East_Sales_Team</group>
        </sharedTo>
    </sharingOwnerRules>
</SharingRules>
```

## Public Group Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Group xmlns="http://soap.sforce.com/2006/04/metadata">
    <name>Sales_Team</name>
    <doesIncludeBosses>true</doesIncludeBosses>
</Group>
```

## CLI Commands for Security

```bash
# Assign permission set to user
sf org assign permset --name Sales_Manager_Access --target-org myorg

# Assign to specific user
sf org assign permset --name Sales_Manager_Access --on-behalf-of user@example.com --target-org myorg

# Retrieve permission sets
sf project retrieve start --metadata "PermissionSet"

# Retrieve specific permission set
sf project retrieve start --metadata "PermissionSet:Sales_Manager_Access"

# Retrieve profiles
sf project retrieve start --metadata "Profile:Admin"

# Retrieve sharing rules
sf project retrieve start --metadata "SharingRules:Account"

# Deploy permission set
sf project deploy start --source-dir force-app/main/default/permissionsets

# Generate user password
sf org generate password --target-org myorg

# Display user details
sf org display user --target-org myorg
```

## Common User Permissions

| Permission API Name | Description |
|---------------------|-------------|
| `ViewAllData` | View all records |
| `ModifyAllData` | Edit all records |
| `ViewSetup` | Access Setup |
| `ManageUsers` | Manage users |
| `ApiEnabled` | API access |
| `BulkApiHardDelete` | Hard delete via Bulk API |
| `ViewAllProfiles` | View all profiles |
| `AssignPermissionSets` | Assign permission sets |
| `ManageCustomPermissions` | Manage custom permissions |
| `RunReports` | Run reports |
| `ExportReports` | Export reports |
| `CreateDashboards` | Create dashboards |
| `ManageDashboards` | Manage dashboards |

## Security Best Practices

1. **Use Permission Sets over Profiles** - More granular, easier to manage
2. **Use Permission Set Groups** - Bundle related permission sets
3. **Principle of Least Privilege** - Grant minimum required access
4. **Document sharing rules** - Maintain clear documentation
5. **Regular access reviews** - Audit permissions periodically
6. **Use roles for hierarchy** - Record access based on role hierarchy
7. **Test in sandbox first** - Validate security changes before production

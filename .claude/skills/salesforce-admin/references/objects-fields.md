# Objects and Fields Reference

## Custom Object Metadata Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>My Object</label>
    <pluralLabel>My Objects</pluralLabel>
    <nameField>
        <label>My Object Name</label>
        <type>Text</type>
    </nameField>
    <deploymentStatus>Deployed</deploymentStatus>
    <sharingModel>ReadWrite</sharingModel>
    <enableActivities>true</enableActivities>
    <enableHistory>true</enableHistory>
    <enableReports>true</enableReports>
    <enableSearch>true</enableSearch>
</CustomObject>
```

## Field Type Templates

### Text Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Description__c</fullName>
    <label>Description</label>
    <type>Text</type>
    <length>255</length>
    <required>false</required>
</CustomField>
```

### Number Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Quantity__c</fullName>
    <label>Quantity</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>0</scale>
    <required>false</required>
</CustomField>
```

### Currency Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Amount__c</fullName>
    <label>Amount</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>
    <required>false</required>
</CustomField>
```

### Date Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Start_Date__c</fullName>
    <label>Start Date</label>
    <type>Date</type>
    <required>false</required>
</CustomField>
```

### DateTime Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Created_DateTime__c</fullName>
    <label>Created Date Time</label>
    <type>DateTime</type>
    <required>false</required>
</CustomField>
```

### Checkbox Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Is_Active__c</fullName>
    <label>Is Active</label>
    <type>Checkbox</type>
    <defaultValue>false</defaultValue>
</CustomField>
```

### Picklist Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Status__c</fullName>
    <label>Status</label>
    <type>Picklist</type>
    <valueSet>
        <restricted>true</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <fullName>New</fullName>
                <default>true</default>
                <label>New</label>
            </value>
            <value>
                <fullName>In Progress</fullName>
                <default>false</default>
                <label>In Progress</label>
            </value>
            <value>
                <fullName>Completed</fullName>
                <default>false</default>
                <label>Completed</label>
            </value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
```

### Multi-Select Picklist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Categories__c</fullName>
    <label>Categories</label>
    <type>MultiselectPicklist</type>
    <visibleLines>4</visibleLines>
    <valueSet>
        <restricted>true</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <fullName>Category A</fullName>
                <default>false</default>
                <label>Category A</label>
            </value>
            <value>
                <fullName>Category B</fullName>
                <default>false</default>
                <label>Category B</label>
            </value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
```

### Lookup Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Account__c</fullName>
    <label>Account</label>
    <type>Lookup</type>
    <referenceTo>Account</referenceTo>
    <relationshipLabel>Related Records</relationshipLabel>
    <relationshipName>Related_Records</relationshipName>
    <deleteConstraint>SetNull</deleteConstraint>
</CustomField>
```

### Master-Detail Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Parent_Account__c</fullName>
    <label>Parent Account</label>
    <type>MasterDetail</type>
    <referenceTo>Account</referenceTo>
    <relationshipLabel>Child Records</relationshipLabel>
    <relationshipName>Child_Records</relationshipName>
    <relationshipOrder>0</relationshipOrder>
    <reparentableMasterDetail>false</reparentableMasterDetail>
    <writeRequiresMasterRead>false</writeRequiresMasterRead>
</CustomField>
```

### Formula Field (Text)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Full_Name__c</fullName>
    <label>Full Name</label>
    <type>Text</type>
    <formula>FirstName__c &amp; " " &amp; LastName__c</formula>
</CustomField>
```

### Formula Field (Number)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Total__c</fullName>
    <label>Total</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>2</scale>
    <formula>Quantity__c * Unit_Price__c</formula>
</CustomField>
```

### Roll-Up Summary Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Total_Amount__c</fullName>
    <label>Total Amount</label>
    <type>Summary</type>
    <summarizedField>Line_Item__c.Amount__c</summarizedField>
    <summaryForeignKey>Line_Item__c.Order__c</summaryForeignKey>
    <summaryOperation>sum</summaryOperation>
</CustomField>
```

### Long Text Area
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Notes__c</fullName>
    <label>Notes</label>
    <type>LongTextArea</type>
    <length>32768</length>
    <visibleLines>6</visibleLines>
</CustomField>
```

### Rich Text Area
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Description_Rich__c</fullName>
    <label>Description</label>
    <type>Html</type>
    <length>32768</length>
    <visibleLines>25</visibleLines>
</CustomField>
```

### Email Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Contact_Email__c</fullName>
    <label>Contact Email</label>
    <type>Email</type>
    <required>false</required>
    <unique>false</unique>
</CustomField>
```

### Phone Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Phone_Number__c</fullName>
    <label>Phone Number</label>
    <type>Phone</type>
    <required>false</required>
</CustomField>
```

### URL Field
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Website__c</fullName>
    <label>Website</label>
    <type>Url</type>
    <required>false</required>
</CustomField>
```

## Retrieve and Deploy Commands

```bash
# Retrieve all custom objects
sf project retrieve start --metadata "CustomObject"

# Retrieve specific object with all fields
sf project retrieve start --metadata "CustomObject:MyObject__c"

# Retrieve specific field
sf project retrieve start --metadata "CustomField:Account.My_Field__c"

# Deploy single object
sf project deploy start --source-dir force-app/main/default/objects/MyObject__c

# Deploy specific field
sf project deploy start --metadata "CustomField:Account.My_Field__c"

# Deploy with test execution
sf project deploy start --source-dir force-app --test-level RunLocalTests
```

## Field-Level Security

After creating fields, grant access via Permission Sets or Profiles:

```xml
<!-- In permissionsets/My_Permission_Set.permissionset-meta.xml -->
<fieldPermissions>
    <editable>true</editable>
    <field>Account.My_Field__c</field>
    <readable>true</readable>
</fieldPermissions>
```

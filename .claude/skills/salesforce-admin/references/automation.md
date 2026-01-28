# Automation Reference

## Flow Types

| Type | Use Case |
|------|----------|
| Screen Flow | User-interactive forms and wizards |
| Record-Triggered Flow | Automate on record create/update/delete |
| Schedule-Triggered Flow | Run at scheduled times |
| Platform Event-Triggered | React to platform events |
| Autolaunched Flow | Called from Apex, Process Builder, or other flows |

## Record-Triggered Flow Metadata

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Flow xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>59.0</apiVersion>
    <label>Account After Insert Handler</label>
    <processType>AutoLaunchedFlow</processType>
    <status>Active</status>
    <start>
        <object>Account</object>
        <triggerType>RecordAfterSave</triggerType>
        <recordTriggerType>Create</recordTriggerType>
        <connector>
            <targetReference>Create_Task</targetReference>
        </connector>
    </start>

    <recordCreates>
        <name>Create_Task</name>
        <label>Create Follow-up Task</label>
        <inputAssignments>
            <field>Subject</field>
            <value>
                <stringValue>Follow up with new account</stringValue>
            </value>
        </inputAssignments>
        <inputAssignments>
            <field>WhatId</field>
            <value>
                <elementReference>$Record.Id</elementReference>
            </value>
        </inputAssignments>
        <inputAssignments>
            <field>OwnerId</field>
            <value>
                <elementReference>$Record.OwnerId</elementReference>
            </value>
        </inputAssignments>
        <object>Task</object>
    </recordCreates>
</Flow>
```

## Flow Entry Conditions

### Record-Triggered Flow Conditions
```xml
<start>
    <object>Opportunity</object>
    <triggerType>RecordAfterSave</triggerType>
    <recordTriggerType>CreateAndUpdate</recordTriggerType>
    <filterLogic>and</filterLogic>
    <filters>
        <field>StageName</field>
        <operator>EqualTo</operator>
        <value>
            <stringValue>Closed Won</stringValue>
        </value>
    </filters>
    <filters>
        <field>Amount</field>
        <operator>GreaterThan</operator>
        <value>
            <numberValue>10000</numberValue>
        </value>
    </filters>
</start>
```

## Common Flow Elements

### Decision Element
```xml
<decisions>
    <name>Check_Amount</name>
    <label>Check Amount</label>
    <defaultConnector>
        <targetReference>Standard_Path</targetReference>
    </defaultConnector>
    <rules>
        <name>High_Value</name>
        <conditionLogic>and</conditionLogic>
        <conditions>
            <leftValueReference>$Record.Amount</leftValueReference>
            <operator>GreaterThan</operator>
            <rightValue>
                <numberValue>100000</numberValue>
            </rightValue>
        </conditions>
        <connector>
            <targetReference>High_Value_Path</targetReference>
        </connector>
        <label>High Value</label>
    </rules>
</decisions>
```

### Update Records
```xml
<recordUpdates>
    <name>Update_Account</name>
    <label>Update Account Status</label>
    <inputAssignments>
        <field>Status__c</field>
        <value>
            <stringValue>Active</stringValue>
        </value>
    </inputAssignments>
    <inputReference>$Record</inputReference>
</recordUpdates>
```

### Create Records
```xml
<recordCreates>
    <name>Create_Case</name>
    <label>Create Case</label>
    <inputAssignments>
        <field>Subject</field>
        <value>
            <stringValue>New Customer Onboarding</stringValue>
        </value>
    </inputAssignments>
    <inputAssignments>
        <field>AccountId</field>
        <value>
            <elementReference>$Record.Id</elementReference>
        </value>
    </inputAssignments>
    <object>Case</object>
    <storeOutputAutomatically>true</storeOutputAutomatically>
</recordCreates>
```

### Get Records
```xml
<recordLookups>
    <name>Get_Related_Contacts</name>
    <label>Get Related Contacts</label>
    <object>Contact</object>
    <filterLogic>and</filterLogic>
    <filters>
        <field>AccountId</field>
        <operator>EqualTo</operator>
        <value>
            <elementReference>$Record.Id</elementReference>
        </value>
    </filters>
    <getFirstRecordOnly>false</getFirstRecordOnly>
    <storeOutputAutomatically>true</storeOutputAutomatically>
</recordLookups>
```

### Loop Element
```xml
<loops>
    <name>Loop_Through_Contacts</name>
    <label>Loop Through Contacts</label>
    <collectionReference>Get_Related_Contacts</collectionReference>
    <iterationOrder>Asc</iterationOrder>
    <nextValueConnector>
        <targetReference>Update_Contact</targetReference>
    </nextValueConnector>
    <noMoreValuesConnector>
        <targetReference>End_Flow</targetReference>
    </noMoreValuesConnector>
</loops>
```

### Assignment Element
```xml
<assignments>
    <name>Set_Variables</name>
    <label>Set Variables</label>
    <assignmentItems>
        <assignToReference>varTotal</assignToReference>
        <operator>Add</operator>
        <value>
            <elementReference>$Record.Amount</elementReference>
        </value>
    </assignmentItems>
</assignments>
```

## Approval Process Metadata

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApprovalProcess xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Opportunity.Discount_Approval</fullName>
    <active>true</active>
    <label>Discount Approval</label>
    <description>Approval required for discounts over 20%</description>

    <entryCriteria>
        <criteriaItems>
            <field>Opportunity.Discount__c</field>
            <operation>greaterThan</operation>
            <value>20</value>
        </criteriaItems>
    </entryCriteria>

    <initialSubmissionActions>
        <action>
            <name>Set_Status_Pending</name>
            <type>FieldUpdate</type>
        </action>
    </initialSubmissionActions>

    <approvalStep>
        <name>Manager_Approval</name>
        <label>Manager Approval</label>
        <allowDelegate>false</allowDelegate>
        <assignedApprover>
            <approver>
                <type>userHierarchyField</type>
            </approver>
        </assignedApprover>
        <entryCriteria>
            <criteriaItems>
                <field>Opportunity.Discount__c</field>
                <operation>lessOrEqual</operation>
                <value>30</value>
            </criteriaItems>
        </entryCriteria>
        <approvalActions>
            <action>
                <name>Set_Status_Approved</name>
                <type>FieldUpdate</type>
            </action>
        </approvalActions>
        <rejectionActions>
            <action>
                <name>Set_Status_Rejected</name>
                <type>FieldUpdate</type>
            </action>
        </rejectionActions>
    </approvalStep>

    <finalApprovalActions>
        <action>
            <name>Send_Approval_Email</name>
            <type>Alert</type>
        </action>
    </finalApprovalActions>

    <finalRejectionActions>
        <action>
            <name>Send_Rejection_Email</name>
            <type>Alert</type>
        </action>
    </finalRejectionActions>
</ApprovalProcess>
```

## CLI Commands for Automation

```bash
# Retrieve all flows
sf project retrieve start --metadata "Flow"

# Retrieve specific flow
sf project retrieve start --metadata "Flow:Account_After_Insert_Handler"

# Retrieve approval processes
sf project retrieve start --metadata "ApprovalProcess"

# Deploy flows
sf project deploy start --source-dir force-app/main/default/flows

# Deploy with test level
sf project deploy start --source-dir force-app/main/default/flows --test-level RunLocalTests
```

## Flow Best Practices

1. **Use meaningful names** - `Account_After_Create_Notify_Owner` not `Flow1`
2. **Add descriptions** - Document the flow's purpose
3. **Use entry conditions** - Filter records before the flow runs
4. **Bulkify operations** - Collect records, update in batch
5. **Handle errors** - Add fault paths for DML operations
6. **Test thoroughly** - Create test data covering all paths
7. **Version control** - Track flow metadata in source control
8. **Deactivate before delete** - Never delete active flows

## Process Builder Migration

Process Builder is retired. Migrate to Flows:

1. **Identify active Process Builders**:
   ```bash
   sf project retrieve start --metadata "Workflow"
   ```

2. **Use Migrate to Flow tool** in Setup > Process Automation Settings

3. **Test migrated Flows** in sandbox

4. **Deactivate Process Builder** after Flow validation

5. **Deploy Flows** to production

# Deploy to Salesforce

Deploy the Enterprise Second Brain Salesforce Metadata to your default org.

## Pre-deployment Steps

1. Ask the user to confirm they want to proceed with the deployment
2. Optionally show them what will be deployed (the contents of salesforce/force-app/main/default)

## Deployment Command

Run this command:

```bash
sf project deploy start --source-dir salesforce/force-app/main/default
```

## Handling Output

The deployment output can be very large. To handle it properly:

1. First check the exit code of the command - non-zero indicates failure
2. If output is too large to read directly, use these commands to extract key information:
   - Check final status: `tail -100 <output-file>`
   - Search for errors: `grep -i "error\|failed\|exception" <output-file>`
   - Get deployment summary: `grep -A 20 "Deployed Source" <output-file>`

## Report to User

Show the user:
- Deployment status (Succeeded/Failed)
- Deploy ID
- Target org
- List of deployed components with their states (Changed/Unchanged)
- Any errors or warnings encountered

## Troubleshooting

If deployment fails:
- Show the specific error messages
- Check that the user's default org is set correctly: `sf config get target-org`
- Verify they have proper permissions in the org

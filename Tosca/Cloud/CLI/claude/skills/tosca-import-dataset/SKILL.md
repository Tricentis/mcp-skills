---
name: tosca-import-dataset
description: Import a CSV, Excel, or JSON file as a new data set in Tosca Cloud
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "<file-path>"
---

# Import a Data Set

Import a CSV, Excel (.xlsx), or JSON file as a new test data set in Tosca Cloud.

Always use `--json --silent` on every `toscactl` command.

## Steps

1. **Parse arguments.** Extract from `$ARGUMENTS`:
   - File path (required)

2. **Verify the file exists** before running the import. Check the file extension is `.csv`, `.xlsx`, `.xls`, or `.json`.

3. **Run the import.**
   ```
   toscactl datasets import "<file_path>" --json --silent
   ```
   This uploads the file to Azure Blob Storage and triggers dataset creation. The command waits up to 300 seconds by default.

   For large files, consider using `--timeout` to increase the wait time:
   ```
   toscactl datasets import "<file_path>" --timeout 600 --json --silent
   ```

4. **Parse the result.** The JSON response contains the creation status and upload results:
   - `status` — `complete` or `terminated`
   - `datasetUploadResults` — array with `datasetId`, `datasetName`, `isSuccess`, and `errorMessage` for each file

5. **Report to the user.** Show the created dataset name and ID. If the import failed, show the error message. Offer to view the dataset with `/tosca-datasets view <id>`.

## Error Handling

- If the file is not found, ask the user to check the path.
- If the import times out, report the job ID so the user can check status later.
- If the import fails with authorization errors, suggest re-authenticating with `/tosca-setup`.

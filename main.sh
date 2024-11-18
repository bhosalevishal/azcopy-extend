#!/bin/sh

sample_blob_url="set-correct-value"
if [ "$BLOB_SAS_URL" = "$sample_blob_url" ] || [ "$BLOB_SAS_URL" = "" ]; then
  echo "⛔ BLOB_SAS_URL environment variable is missing."
  exit 1
else
  blob_sas_url="$BLOB_SAS_URL"
fi

# Define the file where the last execution time is stored
LAST_EXEC_TIME_FILE="last-exec-time.txt"

# Check if the last-exec-time.txt file exists
if [ -f "$LAST_EXEC_TIME_FILE" ]; then
  # Read the last line from the file and store it in last_exec_time
  last_exec_time=$(tail -n 1 "$LAST_EXEC_TIME_FILE")
  echo "Last execution time found: $last_exec_time"
else
  # If the file doesn't exist, set time before 5 minutes as last-exec-time
  last_exec_time=$(date -d@"$(( `date +%s`-300))" -u +"%Y-%m-%dT%H:%M:%SZ")
  echo  "$last_exec_time" > "$LAST_EXEC_TIME_FILE"
  echo "No previous execution found. Store current time as last_exec_time: $last_exec_time"
fi

# Start an infinite loop
while true; do
  # Store the current time in current_exec_time variable
  current_exec_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  echo "\n"
  echo "➡️ Executing AzCopy between include-after: $last_exec_time and include-before: $current_exec_time"

  # Execute the azcopy command to copy files
  azcopy copy "/src/*.jpg" "$blob_sas_url" \
    --recursive=false \
    --overwrite=ifSourceNewer \
    --include-after="$last_exec_time" \
    --include-before="$current_exec_time"

  # Capture the exit status of the azcopy command
  exit_status=$?

  if [ $exit_status -eq 0 ]; then
    echo "AzCopy executed successfully."
	#find /src -type f -newer "$last_exec_time" ! -newer "$current_exec_time" rm -f {} \;

  else
    echo "AzCopy encountered an error. Exit status: $exit_status"
    # Optionally, you can exit or handle the error as needed
    # exit 1
  fi

  # Update last_exec_time to current_exec_time
  last_exec_time="$current_exec_time"

  # Write the new last_exec_time back to the last-exec-time.txt file
  echo "$last_exec_time" > "$LAST_EXEC_TIME_FILE"
  echo "Written new execution time $last_exec_time to $LAST_EXEC_TIME_FILE"

  # Sleep for 60 seconds before repeating the loop
  echo "⌛ Waiting..."
  sleep 60
done

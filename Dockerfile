# Use peterdavehello/azcopy:10.11.0 as the base image
FROM peterdavehello/azcopy:10.11.0

ENV BLOB_SAS_URL="set-correct-value"

# Copy main.sh into the container
COPY main.sh /usr/local/bin/main.sh

# Make main.sh executable
RUN chmod +x /usr/local/bin/main.sh

# Set the default command to use your script (optional)
CMD ["/usr/local/bin/main.sh"]

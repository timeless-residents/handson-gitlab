#!/bin/bash
set -e

echo "Running gitlab-ctl reconfigure..."
gitlab-ctl reconfigure

echo "Starting GitLab services..."
gitlab-ctl start

echo "GitLab is now running."
exec "$@"

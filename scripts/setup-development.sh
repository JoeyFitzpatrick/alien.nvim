# setup-development.sh
#!/bin/sh

# set up git hooks
chmod +x .githooks/pre-push
ln -sf ../../.githooks/pre-push .git/hooks/pre-push

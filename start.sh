#!/bin/zsh

set -euo pipefail
if [ -f "Taskfile" ]; then
    echo "Taskfile already exists: doing nothing"
    exit
fi
curl -fsSL https://raw.githubusercontent.com/acecilia/taskfile/master/taskfile_template -o taskfile
chmod +x taskfile
echo "Done: basic taskfile created"
echo "You can add the task alias to your zsh shell by running the following command and then restarting your shell:"
echo "> echo \"alias task='./taskfile'\" >> ~/.zshrc"
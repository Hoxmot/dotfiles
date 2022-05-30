#!/bin/zsh

if [[ $# -le 0 ]];
then
    echo "Usage: ./tmux.sh session-name";
    exit 1;
fi

SESSION=$1
SCRIPT_PATH=${HOME}/dev/scripts/tmux/${SESSION}.conf

if tmux has-session -t $SESSION 2>/dev/null;
then
    tmux attach-session -t $SESSION;
else
    cd ~
    tmux new -s $SESSION \; \
    source-file $SCRIPT_PATH
fi

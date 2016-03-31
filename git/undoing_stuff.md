# Git - Undoing Stuff

## Removing Stuff From Stage

    git reset

## Resetting Modified File Permissions

    git diff -p -R | grep -E "^(diff|(old|new) mode)" | git apply

To add an alias for re-use:

    git config --global --add alias.permission-reset '!git diff -p -R | grep -E "^(diff|(old|new) mode)" | git apply'

and then execute it with:

    git permission-reset
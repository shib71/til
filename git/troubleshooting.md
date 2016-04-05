# Troubleshooting

## Not a git repository

    fatal: Not a git repository: /home/blair/projects/workbench/bos-env-programbuilder/.git/modules/code/bos-programbuilder

This means that the repo has a submodule, and has been moved around the file system. Git repos normally have a `.git` directory
with a bunch of stuff in it, but in submodules that is just a file pointing to where the information is in host repo. If you
have accidentally lost the original path, it should be `[repo-path]/.git/modules/[submodule-relative-path]`.
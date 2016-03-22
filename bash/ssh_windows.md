# SSH On Windows

Using ssh on windows XP:

- install git bash
- `mkdir `~/.ssh`
- `touch `~/.ssh/config`
- copy ssh keys into C:\Documents and Settings\[your_username]\.ssh\
- edit C:\Documents and Settings\[your_username]\.ssh\config and add:

    Host *.domain.pattern
        IdentityFile ~/.ssh/[key_file]
        User sysadmin
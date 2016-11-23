## File System

### Fixing Directory Permissions

This command will update all sub directories of the current location
to the standard permissions \[[1]\]:

    find . -type d -exec chmod 775 {} \;

[1]: https://odd.blog/2013/11/05/fix-file-644-directory-775-permissions-linux-easily/
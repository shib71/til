## File System

### Fixing Directory Permissions

This command will update all sub directories of the current location
to the standard permissions:

    find . -type d -exec chmod 775 {} \;

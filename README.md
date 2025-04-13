# CLRJOBSPL
Clear Job Spooled File on IBM i

This utility provide a CLI to clear all spooled file a job has generated so far.

## Install
Once the package is cloned as a IFS folder under the user's home (~), or downloa

```
cd [SOURCE_DIRECTORY]
sh setup.sh [TARGET_LIBRARY]
```
For example, sh setup.sh KPI681 will set the source physical file CLRJOBSPL in l

Next use option 14 to compile INSTALLP from the source member. Then
```
call installp
```
The [TARGET_LIBRARY], where the command CLRJOBSPL will reside, obviously should




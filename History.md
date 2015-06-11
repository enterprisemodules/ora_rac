History
========

11-06-2015  version 0.8.8
--------------------------
- Make tmpfs 60% of memory size
- Add all instance names to init.ora

09-06-2015  version 0.8.7
--------------------------
- Fix tmpfs size

04-06-2015  version 0.8.6
--------------------------
- Move undotbs to right place

13-05-2015  version 0.8.5
--------------------------
- removed creating of bash profiles for Oracle and Grid users

16-04-2015  version 0.8.4
--------------------------
- Extracting grid and oracle keys

15-04-2015  version 0.8.3
--------------------------
- Small fixes to ASM disk.
- Don't use fixed group numbers for loggroups

15-04-2015  version 0.8.2
--------------------------
- Change instanc from 2 to 3 logfiles with a size of 512 

10-04-2015  version 0.8.1
--------------------------
- Added a sleep on createing the ASM disks. This waits maximum 120 seconds for any device mapper disks to come online.

08-04-2015  version 0.8.0
--------------------------
- Added the parameter config_scripts to db_master. This is the extension of ora_database config_scripts

01-04-2015  version 0.7.4
--------------------------
- Fixes for ASM restarts
- added diskdiscoverystring to api
- extractes creation of oracle and grid users

25-03-2015  version 0.7.3
--------------------------
- Create a default partition table with type msdos in stead of gpt. msdos partion types are better supported on older versions of redhat.


25-03-2015  version 0.7.1
--------------------------
- Added support for multipath devices


17-04-2015  version 0.7.0
--------------------------
- Working with the latest version of the Oracle module


23-02-2015  version 0.6.7
--------------------------
- Different implementation of user equivalance

......
some versions skipped
......

15-12-2014  version 0.5.6
--------------------------
- Only add instance from current node to oratab file

15-12-2014  version 0.5.0
--------------------------
- Added settings block an check for Puppet version

07-10-2014  version 0.0.3
--------------------------
- Using more custom types to make installation better repeatable.
- Extracted some OS stuff to separate classes to make module more usable
- Removed extra ssh stuff for VIP nodes

29-09-2014  version 0.0.2
--------------------------
Fixed a typo

29-09-2014  version 0.0.1
--------------------------
Initial release

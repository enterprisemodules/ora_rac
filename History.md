History
========

20-04-2016  version 0.10.0
--------------------------
- move to oradb V2
- Add support for hugepages
- remove unused firewall rule


10-12-2015  version 0.8.18
--------------------------
- Remove extra notice

26-11-2015  version 0.8.17
--------------------------
- Export memory_target and memory_max_target on the parameter. This makes it possible to specify these two parameters for an RAC instance

22-10-2015  version 0.8.16
--------------------------
- Add support for setting password of oracle and grid os users.
- fix requires when running on rhel 6

18-08-2015  version 0.8.15
--------------------------
- Fix typo in db_server

18-08-2015  version 0.8.14
--------------------------
- Allow HIGH as value for disk redundancy

16-07-2015  version 0.8.13
--------------------------
- Better idempotency of db_master

14-07-2015  version 0.8.12
--------------------------
- Extracted the creation of authorized nodes from `os_users`. This means you have to include this modules extra `include ora_rac::authenticated_nodes`.

10-07-2015  version 0.8.11
--------------------------
- Fix ownership of Oracle directory on db_server when grid_home and oracle_home have common root paths


24-06-2015  version 0.8.10
--------------------------
- Fix uid of grid user

23-06-2015  version 0.8.9
--------------------------
- Make checks compatible with puppet 3.8 and higher

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

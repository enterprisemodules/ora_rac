export ORACLE_SID=+ASM1
export ORAENV_ASK=NO
. oraenv
sqlplus / as sysasm <<-EOF
create diskgroup DATA normal redundancy failgroup CONTROLLER1 disk 'ORCL:DATAVOL1' name DATAVOL1 failgroup CONTROLLER2 disk 'ORCL:DATAVOL2' name DATAVOL2 ATTRIBUTE 'compatible.asm' = '11.2', 'compatible.rdbms' = '11.2';
create diskgroup REDO normal redundancy failgroup CONTROLLER1 disk 'ORCL:REDOVOL1' name REDOVOL1 failgroup CONTROLLER2 disk 'ORCL:REDOVOL2' name REDOVOL2 ATTRIBUTE 'compatible.asm' = '11.2', 'compatible.rdbms' = '11.2';
EOF


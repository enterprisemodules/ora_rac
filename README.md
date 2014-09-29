
####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with ora_rac](#setup)
    * [What ora_rac affects](#what-ora_rac-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ora_rac](#beginning-with-ora_rac)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
    * [OS support](#os-support)
    * [Oracle versions support](#oracle-version-support)
    * [Tests - Testing your configuration](#testing)

##Overview

This module contains all classes needed to successfully install an Oracle RAC cluster. This module is based heavily on the [oradb module](https://forge.puppetlabs.com/biemond/oradb) Edwin Biemond.

##Module Description
The module contains two main definitions. A `db_master` and a `db_server`.  These are the main classes for defining the two or more nodes in a RAC cluster. 

Next to these two main classes, the module contains supporting classed to get the environment needed to get a RAC node running. Some of these classes can (and should) be  included in your own definition of a RAC node. Other classed are just samples of what you could do. These sample classed are used in the two  example's we provide. 

We crafted two examples. A set of vagrant boxes installing an Oracle 11.2.0.4 RAC cluster. You can find them [here](https://github.com/hajee/vagrant-ora11-rac). We've also made a more current box showing an Oracle 12c RAC cluster. Those boxes can be found [here](https://github.com/hajee/vagrant-ora12-rac). For guidance, you can look at their definition


##Setup

###What ora_rac affects
To build an Oracle RAC system, you need at least two machines. Best is to have them dedicated for database serving purposes. The classes affect a lot of system components. The following modifications are made to the system:

* users and groups are added
* ssh keys are added for those users and access between nodes is based on these keys.
* `sysctl` parameters are added.
* rules are added to the `iptables`
* a set of required rpm packages are installed.
* oracle and grid software is installed

###Setup Requirements

To run the `ora_rac` classes, you need:

* hajee/oracle         >= 0.4.0'
* biemond/oradb    >= 1.0.17

For running the demo boxes you also need:

* hajee/partition
* hajee/hacks

The provided `Modulefile` manages all requirements so you can install the `ora_rac` module with:

```sh
$ puppet module install hajee-ora_rac
```

###Beginning with ora_rac module

Like mentioned before, this module builds on the module [oradb module](https://forge.puppetlabs.com/biemond/oradb). A lot of the specific parameters you can use, are directly forwarded to: 

* `oradb::installdb`
* `oradb::installasm`
* `oradb::database`

So if you need some more documentation, check out the documentation of those classes.

##Usage

Although Oracle RAC doesn't normally use these concepts, we introduce it here to explain their role during deployment. A `db_master` is the first node we need to deploy. To install RAC on the `db_master`, the `db_master` needs access to the software for installing Oracle and the software for installing Oracle grid.

A `db_server` on the other hand clones all needed software from the `db_master` in the RAC cluster.

##Limitations

 This module is tested with Oracle 11.2.0.4 and Oracle 12.1.0.1 on CentOS 5.10It will probably work on other Linux distributions. It will definitely **not** work on Windows. As far as Oracle compatibility.

##Development

This is an open source project, and **ALL** contributions are welcome.

###OS support

Currently, we have tested:

* CentOS 5.10

It would be great if we could get it working and tested on:

* Oracle 12
* Debian
* Ubuntu
* ....

###Oracle version support

Currently we have tested:

* Oracle 11.2.0.4
* Oracle 12.1.0.1

###Testing

No tests yet
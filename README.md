
[![Enterprise Modules](https://raw.githubusercontent.com/enterprisemodules/public_images/master/banner1.jpg)](https://www.enterprisemodules.com)

#### Table of Contents

1. [Overview](#overview)
2. [License](#license)
3. [Description - What the module does and why it is useful](#description)
4. [Setup](#setup)
  * [Requirements](#requirements)
  * [Installing the ora_config module](#installing-the-ora_config-module)
5. [Usage - Configuration options and additional functionality](#usage)
6. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
7. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This module allows you to configure and manage an Oracle RAC cluster.
It is part of our family of Puppet modules to install, manage and secure Oracle databases with Puppet. Besides the `ora_rac` module, this family also contains:

- [ora_install](https://www.enterprisemodules.com/shop/products/puppet-ora_install-module?taxon_id=14) For installing an Oracle database and other database related Oracle products
- [ora_config](https://www.enterprisemodules.com/shop/products/puppet-ora_config-module?taxon_id=14) For configuring every aspect of your Oracle database
- [ora_cis](https://www.enterprisemodules.com/shop/products/puppet-oracle-security-module?taxon_id=14) To secure your databases according to the CIS benchmarks.

## License

Most of the [Enterprise Modules](https://www.enterprisemodules.com) modules are commercial modules. This one is **NOT**. It is an Open Source module. You are free to use it any way you like. It however is based on our commercial Puppet Oracle modules.

## Description

The module contains two main definitions. A `db_master` and a `db_server`. These are the main classes for defining the two or more nodes in a RAC cluster. 

Next to these two main classes, the module contains supporting classed to get the environment needed to get a RAC node running. Some of these classes can (and should) be  included in your own definition of a RAC node. Other classed are just samples of what you could do. These sample classed are used in the two  example's we provide.


## Setup

### Requirements

To build an Oracle RAC system, you need at least two machines. Best is to have them dedicated for database serving purposes. The classes affect a lot of system components. The following modifications are made to the system:


The `ora_rac` module requires:

- Puppet module [`enterprisemodules-easy_type`](https://forge.puppet.com/enterprisemodules/easy_type) installed.
- Puppet module [`enterprisemodules-ora_config`](https://forge.puppet.com/enterprisemodules/ora_config) installed.
- Puppet module [`enterprisemodules-ora_install`](https://forge.puppet.com/enterprisemodules/ora_install) installed.
- Puppet version 3.0 or higher. Can be Puppet Enterprise or Puppet Open Source
- Oracle 11 higher
- A valid Oracle license
- A valid Enterprise Modules license for usage.
- Runs on most Linux systems.
- Runs on Solaris
- Windows systems are **NOT** supported

### Installing the ora_rac module

To install these modules, you can use a `Puppetfile`

```
mod 'enterprisemodules/ora_rac'               ,'x.x.x'
```

Then use the `librarian-puppet` or `r10K` to install the software.

You can also install the software using the `puppet module`  command:

```
puppet module install enterprisemodules-ora_rac
```

## Usage

## Reference

Here you can find some more information regarding this puppet module:

Here are a related blog posts:
- [How to ensure you only use Oracle features you paid for](https://www.enterprisemodules.com/blog/2017/09/how-to-ensure-you-only-use-oracle-features-you-paid-for/)
- [Oracle 12.2 support added to our Oracle modules](https://www.enterprisemodules.com/blog/2017/03/oracle12-2-support/)
- [Secure your Oracle Database](https://www.enterprisemodules.com/blog/2017/02/secure-your-oracle-database/)
- [Manage Oracle containers with Puppet](https://www.enterprisemodules.com/blog/2017/01/manage-oracle-containers-with-puppet/)
- [Manage your oracle users with Puppet](https://www.enterprisemodules.com/blog/2016/10/manage-oracle-users-with-puppet/)
- [Reaching into your Oracle Database with Puppet](https://www.enterprisemodules.com/blog/2015/12/reaching-into-your-oracle-database-with-puppet/)
- [Manage your Oracle database schemas with Puppet](https://www.enterprisemodules.com/blog/2015/12/manage-your-oracle-database-schemas-with-puppet/)
- [Managing your Oracle database size with Puppet](https://www.enterprisemodules.com/blog/2015/11/managing-your-oracle-database-size-with-puppet/)
- [Using Puppet to manage Oracle](https://www.enterprisemodules.com/blog/2014/02/using-puppet-to-manage-oracle/)


## Limitations

This module runs on  most Linux versions. It requires a puppet version higher than 4. The module does **NOT** run on windows systems.



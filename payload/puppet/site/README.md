role
====

Using the [Puppet Roles and Profiles](http://www.craigdunn.org/2012/05/239/) design pattern, this module defines roles for nodes.  Each role consists of one or more profiles.

Roles:
* Encapsulate the business requirements of a node (i.e. "development app server")
* Contain one or more profiles
* Contain no specific technical configuration

A node can have **only one role**.

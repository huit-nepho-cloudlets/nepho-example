nepho-example
=============

This is an example cloudlet for [nepho](http://github.com/huit/nepho) that demonstrates key concepts and structure. To get started with your own cloudlet, fork this example and customize it to meet your needs.

Key Concepts
------------
1. All Nepho cloudlets contain a `cloudlet.yaml` metadata file, one or more **blueprints** and their associated **resources**, and implementations of four required **hooks**: `bootstrap`, `configure`, `deploy`, and `teardown` (any or all of which can be a no-op).
2. Blueprints consist of a definition file (in YAML format) and associated resources for spinning up a **stack** using one of Nepho's **provider** plugins, such as "aws" or "vagrant".  The blueprint definition file includes a list of required (and optional) parameters.  Nepho combines the blueprint definition, user-provided parameters, and global configuration defaults to create a **scenario**, which is then passed to the **provider** for implementation.
3. The location and content of blueprint resources varies by provider -- it is up to the provider to define these requirements.  For example, the **vagrant** provider requires that a single `Vagrantfile` be present in the resource directory corresponding to the blueprint (e.g. `resources/vagrant-single-host/Vagrantfile`).  The **aws** provider requires that a CloudFormation template be present at a similar location.
4. Cloudlet packagers may optionally make use of the templating features of [Jinja2](http://jinja.pocoo.org/docs/) to simplify templates and avoid repetition.  All Nepho providers are required to process template files through Jinja2.  The Nepho maintainers provide an [aws-template-library](https://github.com/cloudlets/aws-template-library/) that includes a variety of useful CloudFormation template snippets for AWS.

Hooks
-----
**bootstrap**  
The `bootstrap` hook is called after an instance is fully booted, and will be run _on instance creation_, to bootstrap an instance to a level where the `configure` hook can be run.  In this example cloudlet, the `bootstrap` hook is a very comprehensive implementation that sets up a stock Debian, Ubuntu, Amazon Linux, Red Hat, or CentOS instance with required packages and configuration to run Puppet.  The `bootstrap` hook should do no more and no less than prepare an instance for the `configure` hook.

**configure**  
This hook is typically used to launch a configuration management (CM) tool, in this case Puppet.  The `configure` hook should be idempotent, meaning it can be run multiple times and always bring the instance to a desired state, without causing negative effects.  In this example the Puppet process is run twice, which helps to compensate for dependency and timing errors that can occur on a first run, especially with complex configurations.

**deploy**  
This hook is used to prepare an application or service. Examples of the use of the `deploy` hook include downloading and installing executable code, populating a database, joining a cluster, or simply printing instructions for a user to perform these steps manually (or with an existing tool).  The `deploy` hook should be sufficiently robust that it can be run multiple times without causing harm.  In this example, the `deploy` hook is a no-op.

**teardown**
The `teardown` hook is run just prior to destroying an instance.  It is an opportunity to perform cleanup actions such as backing up data, de-registering from a load balancer, etc.  Ini this example, the `teardown` hook is a no-op.

Included Blueprints
-------------------
**aws-bootstrap**
This blueprint spins up a single Amazon Linux instance, runs the bootstrap sequence, and then executes a command to generate an AMI from the resulting state.  It outputs an explanation message and the newly created AMI's ImageID.  This same process is applicable to other Linux VMs with minor changes to the UserData section of the Cloudformation template to support installing the AWS tools.  The returned ImageID can be manually added as a parameter which is then used by future blueprints.

**aws-single-host**
This blueprint creates a single Amazon Linux host and ties it to an elastic IP and a security group.  It also demonstrates the use of wait conditions.  The CloudFormation template is generated from a collection of Jinja2 template snippets, which you can take advantage of to simplify repetitive CloudFormation syntax.  You can view the full generated template along with validation information by running `nepho stack validate`, or dump it to a file by piping the output of `nepho stack show-template`.

**aws-simple**
This blueprint is similar to the `aws-single-host` example, but has fewer moving parts and relies only minimally on Jinja2 templating.  It launches a single micro instance and assigns it an elastic IP and a security group permitting access to ports 22 (SSH) and 80 (HTTP).  An exercise to the user is using the `aws-simple` blueprint to deploy a simple website.  Hint: there is no need to rely on Puppet or complicated bootstrap scripts for such a simple use case.  Instead, make the `bootstrap` hook a no-op and create a minimal `configure` hook in Bash that installs and runs Apache.

**vagrant-single-host**
Launch a local Vagrant instance running CentOS 6.  This blueprint demonstrates how to run the bootstrapping sequence with Vagrant and how to pass in Nepho parameters as environment variables.

Recommended Best Practices
--------------------------
- The bootstrap process can sometimes be time-consuming, especially if it includes updating packages. Use [packer](http://www.packer.io/) or another tool to turn a bootstrapped VM into a Vagrant box or AMI, and then pass that Box URL or AMI ImageID into your other blueprints as a parameter. If you are only using AWS, look at the `aws-bootstrap` blueprint for an example of how to provide users with the ability to bootstrap an instance themselves using Nepho.

Limitations
-----------
- The `teardown` hook is currently unimplemented in both AWS and Vagrant. Future Vagrant functionality will allow for firing a `teardown` action as part of `vagrant destroy`.

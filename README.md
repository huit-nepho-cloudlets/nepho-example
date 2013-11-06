nepho-example
=============

This is an example cloudlet for [nepho](http://github.com/huit/nepho) that demonstrates key concepts and structure.

Key Concepts
------------
1. All Nepho cloudlets contain a `cloudlet.yaml` metadata file, one or more **blueprints** and their associated **resources**, and implementations of four required **hooks**: `bootstrap`, `configure`, `deploy`, and `teardown` (any or all of which can be a no-op).
2. Blueprints consist of a definition file (in YAML format) and associated resources for spinning up a **stack** using one of Nepho's **provider** plugins, such as "aws" or "vagrant".  The blueprint definition file includes a list of required (and optional) parameters.  Nepho combines the blueprint definition, user-provided parameters, and global configuration defaults to create a **scenario**, which is then passed to the **provider** for implementation.
3. The location and content of blueprint resources varies by provider -- it is up to the provider to define these requirements.  For example, the **vagrant** provider requires that a single `Vagrantfile` be present in the resource directory corresponding to the blueprint (e.g. `resources/vagrant-single-host/Vagrantfile`).  The **aws** provider requires that a CloudFormation template be present at a similar location.
4. Cloudlet packagers may optionally make use of the templating features of [Jinja2](http://jinja.pocoo.org/docs/) to simplify templates and avoid repetition.  All Nepho providers are required to process template files through Jinja2.  The Nepho maintainers provide an **aws-stdlib** that includes a variety of useful CloudFormation template snippets for AWS.

Hooks
-----
**bootstrap**  
The `bootstrap` hook is called after an instance is fully booted, and will be run _only once_, to bootstrap an instance to a level where the `configure` hook can be run.  In this example cloudlet, the `bootstrap` hook is a very comprehensive implementation that sets up a stock Debian, Ubuntu, Amazon Linux, Red Hat, or CentOS instance with required packages and configuration to run Puppet.  The `bootstrap` hook should do no more and no less than prepare an instance for the `configure` hook.

**configure**  
This hook is typically used to launch a configuration management (CM) tool, in this case Puppet.  The `configure` hook should be idempotent, meaning it can be run multiple times and always bring the instance to a desired state, without causing negative effects.  In this example the Puppet process is run twice, which is often good practice due to dependencies and timing errors that can occur on a first run, especially with complex configurations.

**deploy**  
This hook is used to prepare an application or service. Examples of the use of the `deploy` hook include downloading and installing executable code, populating a database, joining a cluster, or simply printing instructions for a user to perform these steps manually (or with an existing tool).  The `deploy` hook should be sufficiently robust that it can be run multiple times without causing harm.  In this example, the `deploy` hook is a no-op.

**teardown**
The `teardown` hook is run just prior to destroying an instance.  It is an opportunity to perform cleanup actions such as backing up data, de-registering from a load balancer, etc.  Ini this example, the `teardown` hook is a no-op.

Limitations
-----------
- Running the complete bootstrap process in this example cloudlet can take a long time. For distributed cloudlets, the current recommendation is to provide a base AMI, Vagrant box, or equivalent that has been pre-bootstrapped.  The example `bootstrap` hook in this cloudlet implements this best practice by checking to see if it has already been run before continuing.

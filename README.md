nepho-example
=============

This is an example cloudlet for [nepho](http://github.com/huit/nepho) that demonstrates key concepts and structure.

Key Concepts
------------
1. All Nepho cloudlets contain a `cloudlet.yaml` metadata file, one or more **blueprints**, additional **data**, and implementations of three required **hooks**: `bootstrap`, `configure`, and `deploy` (any or all of which can be a no-op).
2. Blueprints are YAML documents that provide a list of input parameters that the user will be prompted to enter, and which will then be passed to the provider plugin.  A combination of inputted parameters and a blueprint are called a **scenario**, and are used to launch a running instance of the environment, called a **stack**.
3. The format of the data directory and the accepted parameters are specified by the provider plugin itself. For example, the `vagrant` provider plugin requires only that a valid `Vagrantfile` be present in a directory under `data` named the same as the blueprint.

Hooks
-----
**bootstrap**  
The `bootstrap` hook is the first hook run, and is meant to be run _only once_, to bootstrap an instance to a level where the `configure` hook can be run.  In this example cloudlet, the `bootstrap` hook is a very comprehensive implementation that sets up a stock Debian, Ubuntu, Amazon Linux, Red Hat, or CentOS instance with required packages and configuration to run Puppet.  The `bootstrap` hook should do no more and no less than prepare an instance for the `configure` hook.

**configure**  
This hook is typically used to launch a configuration management (CM) tool, in this case Puppet.  The `configure` hook should be idempotent, meaning it can be run multiple times and always bring the instance to a desired state, without causing negative effects.  In this example the Puppet process is run twice, which is often good practice due to dependencies and timing errors that can occur on a first run, especially with complex configurations.

**deploy**  
The final hook is `deploy`, which is used to prepare an application/service. Examples of the use of the `deploy` hook include downloading and installing executable code, populating a database, joining a cluster, or simply printing instructions for a user to perform these steps manually (or with an existing tool).  The `deploy` hook should be sufficiently robust that it can be run multiple times without causing harm.  In this example, the `deploy` hook is a no-op.

Limitations
-----------
- Currently this cloudlet only supports the "vagrant" nepho provider plugin, in the future it may be expanded to support other provider backends.
- Running the complete bootstrap process in this example cloudlet can take a long time. For distributed cloudlets, the current recommendation is to provide a base AMI, Vagrant box, or equivalent that has been pre-bootstrapped.  The example `bootstrap` hook in this cloudlet automatically checks to see if it has already been run before continuing.

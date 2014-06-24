# VGX Dynamic Vagrant Configuration

VGX provides a dynamic Vagrant configuration that can be used for any project.
Vagrant is generally used on a per-project basis where every project has it's
own Vagrantfile that determines how Vagrant operates within that one
directory/project.  Additionally, Vagrant does not dynamically
support multiple boxes and providers "out-of-the-box", making it difficult to
use one Vagrantfile to test the same project in multiple different
environments.

Our use case involves the need to run tests across multiple different OS
distributions and versions, as well as on different providers (VirtualBox,
Rackspace, Digital Ocean, etc).  With VGX, we have access to all of this
regardless of what project we are working on.

## Quickstart

The following is a quickstart that gets you up and running with Vagrant+VGX

```
$ git clone git@github.com:trueability/vgx.git

$ cd vgx

[vgx] $ export VAGRANT_VAGRANTFILE `pwd`/Vagrantfile

[vgx] $ cp examples/boxes/* boxes
```

Now use Vagrant anywhere:

```
$ cd /path/to/myproject

[myproject] $ vagrant status
centos                    not created (virtualbox)
centos-6                  not created (virtualbox)
suse                      not created (virtualbox)
suse-13.1                 not created (virtualbox)
ubuntu                    not created (virtualbox)
ubuntu-12.04              not created (virtualbox)
ubuntu-14.04              not created (virtualbox)

[myproject] $ vagrant up ubuntu

[myproject] $ vagrant ssh ubuntu

[myproject] $ vagrant destroy ubuntu
```


To modify how VGX and Vagrant function, you can adjust the following
environment variables.  Note that `VGX_ROOT` is always the full path where
the VGX Vagrantfile lives:

 * `VGX_BOXES`: The directory where box configurations are parsed.
   * Default:
     * Global: `${VGX_ROOT}/boxes`
     * Per Project: `./vagrant/boxes`
 * `VGX_PROVIDERS`: The directory where provider configurations are parsed.
   * Default:
     * Global: `${VGX_ROOT}/providers`
     * Per Project`./vagrant/providers`
 * `VGX_BOOTSTRAP`: The path to a script that is run every time a VM is `up`d.
   * Default:
     * Global: `${VGX_ROOT}/scripts/bootstrap`
     * Per Project: `./vagrant/scripts/bootstrap`


## Installation and Setup

VGX is currently only available from GitHub:

```
$ git clone git@github.com:trueability/vgx.git

$ export VAGRANT_VAGRANT_FILE /path/to/vgx/Vagrantfile
```

By default, no VGX boxes are configured.

```
$ vagrant status
Current machine states:

default                   not created (virtualbox)
```

You can simply copy the example box configurations to `${VGX_ROOT}/boxes`
or if using on a per-project basis you can copy them to `./vagrant/boxes`
in your project directory:

```
$ cd /path/to/myproject

[myproject] $ mkdir -p vagrant/boxes

[myproject] $ cp /path/to/vgx/examples/boxes/* vagrant/boxes/

[myproject] $ vagrant status
Current machine states:

centos                    not created (virtualbox)
centos-6                  not created (virtualbox)
suse                      not created (virtualbox)
suse-13.1                 not created (virtualbox)
ubuntu                    not created (virtualbox)
ubuntu-12.04              not created (virtualbox)
ubuntu-14.04              not created (virtualbox)
```


### Configuring Boxes

VGX comes with a growing number of box configs in the `examples/boxes`
directory.  These configurations are simple, and something look like:

```
---
virtualbox: http://files.trueability.com/ta-ubuntu-12.04-x86_64.box
rackspace: /Ubuntu 12.04/
digital_ocean: /Ubuntu 12.04/
```

The box configuration simply defines a necessary identifier that tells the
provider where or how to find the box image/url.  The key thing to note is
that the same configuration will work for any supported provider.  For example
you can do the following with the same box:

```
[vgx] $ vagrant up ubuntu

[vgx] $ vagrant up ubuntu --provider rackspace

[vgx] $ vagrant up ubuntu --provider digital_ocean
```

The idea being, that you can test not only on multiple distributions, but also
across multiple providers to ensure maximum compatibility (depending on your
use case).


### Configuring Providers

By default, no additional provider configurations are added.  That said,
you can tweak Vagrant by adding provider configurations.  For example,
this is a configuration for the Rackspace provider that we'd need to make
Vagrant work with our VGX setup:

**examples/providers/rackspace**

```
x.vm.provider :rackspace do |rs, override|
  override.ssh.private_key_path = RS_PRIVATE_KEY_PATH
  override.vm.box = "rs-dummy"
  override.vm.box_url = RS_BOX_URL
  rs.username = RS_USERNAME
  rs.api_key = RS_API_KEY
  rs.server_name = id
  rs.flavor = RS_FLAVOR
  rs.image = box_config['rackspace']
  rs.public_key_path = RS_PUBLIC_KEY_PATH
end
```

If you intend to use the `vagrant-rackspace` plugin (provider), then you would
need to copy the above to `providers/rackspace` and modify all of the VARIABLES to
set Vagrant up for our environment.  Note the use of `box_config['rackspace']`.  This
is a key/value dictionary that is setup in the Vagrantfile.

Current supported/tested providers include:

 * VirtualBox
 * Rackspace
 * Digital Ocean

Currently, in order to support more providers they will need to be manually added to
the Vagrantfile in order to add the image/url to the `box_config` dictionary.

#### Using the Rackspace Provider

You will need to install the `vagrant-rackspace` plugin/provider.  Then:

```
[vgx] $ cp -a examples/providers/rackspace providers/rackspace
```

Modify the `providers/rackspace` file to meet your needs, and then `up` a box:

```
[vgx] $ vagrant up ubuntu --provider rackspace
```

#### Using the Digital Ocean Provider

You will need to install the `vagrant-digitalocean` plugin/provider.  Then:

```
[vgx] $ cp -a examples/providers/digital_ocean providers/digital_ocean
```

Modify the `providers/digital_ocean` file to meet your needs, and then `up` a box:

```
[vgx] $ vagrant up ubuntu --provider digital_ocean
```

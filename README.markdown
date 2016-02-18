#consul_template for Puppet

[![Build Status](https://travis-ci.org/jaxxstorm/puppet-consul.svg?branch=master)](https://travis-ci.org/jaxxstorm/puppet-consul)

### Important Note
This module has been forked from [gdhbaston's](https://github.com/gdhbashton/puppet-consul_template) and makes lots of changes. I wouldn't recommend switching without serious testing

##Installation

###What This Module Affects

* Installs the consul-template binary (via url or package)
* Optionally installs a user to run it under
* Installs a configuration file (/etc/consul-template/config.json)
* Manages the consul-template service via upstart, sysv, or systemd


##Parameters

- `purge_config_dir` **Default**: true. If enabled, removes config files no longer managed by Puppet.
- `config_mode` **Default**: 0660. Mode set on config files and directories.
- `bin_dir` **Default**: /usr/local/bin. Path to the consul-template binaries
- `arch` **Default**: Read from facter. System architecture to use (amd64, x86_64, i386)
- `version` **Default**: 0.11.0. Version of consul-template to install
- `install_method` **Default**: url. When set to 'url', consul-template is downloaded and installed from source. If
set to 'package', its installed using the system package manager.
- `os` **Default**: Read from facter.
- `download_url` **Default**: undef. URL to download consul-template from (when `install_method` is set to 'url')
- `download_url_base ` **Default**: https://github.com/hashicorp/consul-template/releases/download/ Base URL to download consul-template from (when `install_method` is set to 'url')
- `download_extension` **Default**: zip. File extension of consul-template binary to be downloaded (when `install_method` is set to 'url')
- `package_name` **Default**: consul-template. Name of package to install
- `package_ensure` **Default**: latest.
- `config_dir` **Default**: /etc/consul-template. Path to store the consul-template configuration
- `extra_options` Default: ''. Extra options to be passed to the consul-template daemon. See https://github.com/hashicorp/consul-template#options. config_hash is preferred.
- `service_enable` Default: true.
- `service_ensure` Default: running.
- `restart_on_change` Default: true. Whether to restart the consul agent when config changes are made
- `manage_service` Default: true. Whether to manage the service with puppet, or let something else do it
- `user` Default: consul-template.
- `group` Default: consul-template.
- `manage_user` Default: false. Module handles creating the user.
- `manage_group` Default: false. Module handles creating the group.
- `init_style` Init style to use for consul-template service.
- `log_level` Default: info. Logging level to use for consul-template service. Can be 'debug', 'warn', 'err', 'info'
- `config_hash` Default: {}. A hash of configuration options for consul-template. See https://github.com/hashicorp/consul-template#options
- `pretty_config` Default: false. Whether to pretty up the config json.
- `pretty_config_indent` Default: 4. How much indentation on the config json.



##Usage

The simplest way to use this module is:
```puppet
include consul_template
```

By default the only option that will be set will be the `consul` option, which defaults to
`localhost:8500`

You can specify other config options using the `config_hash` parameter:
```puppet
class { 'consul_template':
    service_enable   => false,
    config_hash => {
       consul     => 'consul.service.discover:8500',
       retry      => '10s',
       log_level  => 'warn',
       ssl => {
         enabled  => true,
         verify   => false,
         cert     => '/path/to/client/cert.pem'
       }
       vault => {
         address => 'https://vault.service.consul:8200',
         token   => '1234567890'
         ssl => {
           enabled => true,
         }
       }
    }
}
```


## Watch files

To declare a file that you wish to populate from Consul key-values, you use the
`watch` define. This requires a source `.ctmpl` file and the file on-disk
that you want to update.

```puppet
consul_template::watch { 'common':
    template      => 'data/common.json.ctmpl.erb',
    template_vars => {
        'var1' => 'foo',
        'var2' => 'bar',
    },
    destination   => '/tmp/common.json',
    command       => 'true',
}
```

##Limitations

Depends on the JSON gem, or a modern ruby.

##Development
See the [contributing guide](CONTRIBUTING.md)

Open an [issue](https://github.com/gdhbashton/puppet-consul_template/issues) or
[fork](https://github.com/gdhbashton/puppet-consul_template/fork) and open a
[Pull Request](https://github.com/gdhbashton/puppet-consul_template/pulls)

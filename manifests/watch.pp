# == Definition consul_template::watch
#
# This definition is called from consul_template
# This is a single instance of a configuration file to watch
# for changes in Consul and update the local file
define consul_template::watch (
  $ensure     = present,
  $template,
  $destination,
  $command = undef,
  $perms = undef,
  $backup = undef,
) {
  include consul_template

  if ( ! $template ) {
    fail ('You must pass a ctmpl file for consul-template to read')
  }

  if ( ! $destination ) {
    fail ('You must pass a destination file for consul-template to write')
  }

  if ($backup) {
    validate_bool($backup)
  }

  $watch_hash = {
    'source'      =>  "${consul_template::config_dir}/templates/${name}.ctmpl",
    'destination' =>  $destination,
    'command'     =>  $command,
    'perms'       =>  $perms,
    'backup'      =>  $backup,
  }

  file { "${consul_template::config_dir}/templates/${name}.ctmpl":
    ensure  => $ensure,
    owner   => $consul_template::user,
    group   => $consul_template::group,
    mode    => $consul_template::config_mode,
    content => template($template),
  }->
  file { "${consul_template::config_dir}/watch_${name}.json":
    ensure  => $ensure,
    owner   => $consul_template::user,
    group   => $consul_template::group,
    mode    => $consul_template::config_mode,
    content => consul_template_sorted_json($watch_hash, $consul_template::pretty_config, $consul_template::pretty_config_indent),
    notify  => Service['consul-template'],
  }



}

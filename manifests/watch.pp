# == Definition consul_template::watch
#
# This definition is called from consul_template
# This is a single instance of a configuration file to watch
# for changes in Consul and update the local file
define consul_template::watch (
  $ensure     = present,
  $template,
  $destination,
  $source = undef,
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

  if ($perms) {
    validate_string($perms)
    validate_re($perms, '[0-7]{4}', 'Must be a valid Unix file permission')
  }

  if (! $source) {
    $source_real = "${consul_template::config_dir}/templates/${name}.ctmpl"
  } else {
    $source_real = $source
  }


  $template_hash = {
    'source'      =>  $source_real,
    'destination' =>  $destination,
    'command'     =>  $command,
    'perms'       =>  $perms,
    'backup'      =>  $backup,
  }
  validate_hash($template_hash)

  $watch_hash = {
    template => [delete_undef_values($template_hash)]
  }

  file { $source_real:
    ensure  => $ensure,
    owner   => $consul_template::user,
    group   => $consul_template::group,
    mode    => $consul_template::config_mode,
    content => template($template),
  }->
  file { "${consul_template::config_dir}/config/watch_${name}.json":
    ensure  => $ensure,
    owner   => $consul_template::user,
    group   => $consul_template::group,
    mode    => $consul_template::config_mode,
    content => consul_template_sorted_json($watch_hash, $consul_template::pretty_config, $consul_template::pretty_config_indent),
    notify  => Service['consul-template'],
  }



}

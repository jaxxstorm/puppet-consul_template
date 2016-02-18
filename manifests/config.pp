# == Class consul_template::config
#
# This class is called from consul_template for service config.
#
class consul_template::config (
  $config_hash,
  $purge = true,
) {

  file { $consul_template::config_dir:
    ensure  => 'directory',
    purge   => $purge,
    recurse => $purge,
    owner   => $consul_template::user,
    group   => $consul_template::group,
    mode    => '0755',
  } ->
  file { "${consul_template::config_dir}/templates":
    ensure  => 'directory',
    purge   => $purge,
    recurse => $purge,
    owner   => $consul_template::user,
    group   => $consul_template::group,
    mode    => '0755',
  } -> 
  file { 'consul-template config.json':
    ensure  => present,
    path    => "${consul_template::config_dir}/config.json",
    owner   => $consul_template::user,
    group   => $consul_template::group,
    mode    => $consul_template::config_mode,
    content => consul_template_sorted_json($config_hash, $consul_template::pretty_config, $consul_template::pretty_config_indent),
    notify  => Service['consul-template'],
  }

}

# == Class consul_template::config
#
# This class is called from consul_template for service config.
#
class consul_template::config (
  $consul_host,
  $consul_port,
  $consul_token,
  $consul_retry,
  $config_hash,
  $purge = true,
) {

  # Set wait param if specified
  if $::consul_template::consul_wait {
    concat::fragment { 'consul_wait':
      target  => 'consul-template/config.json',
      content => inline_template("wait = \"${::consul_template::consul_wait}\"\n\n"),
      order   => '02',
    }
  }

  file { [$consul_template::config_dir, "${consul_template::config_dir}/config"]:
    ensure  => 'directory',
    purge   => $purge,
    recurse => $purge,
    owner   => $consul_template::user,
    group   => $consul_template::group,
    mode    => '0755',
  } ->
  file { 'consul additional config.json':
    ensure  => present,
    path    => "${consul_template::config_dir}/config.json",
    owner   => $consul_template::user,
    group   => $consul_template::group,
    mode    => $consul_template::config_mode,
    content => consul_template_sorted_json($config_hash, $consul_template::pretty_config, $consul_template::pretty_config_indent),
    notify  => Service['consul-template'],
  }

}

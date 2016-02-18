require 'spec_helper'

describe 'consul_template' do
  
  RSpec.configure do |c|
    c.default_facts = {
      :architecture               => 'x86_64',
      :operatingsystem            => 'Ubuntu',
      :osfamily                   => 'Debian',
      :operatingsystemrelease     => '10.04',
      :operatingsystemmajrelease  => '10.04',
      :kernel                     => 'Linux',
      :lsbdistrelease             => '10.04',
      :staging_http_get           => 'curl',
      :path                       => '/usr/bin:/bin:/usr/sbin:/sbin',
    }
  end

  # Installation Stuff
  context 'On an unsupported arch' do
    let(:facts) {{ :architecture => 'bogus' }}
    let(:params) {{
      :install_method => 'package'
    }}
    it { expect { should compile }.to raise_error(/Unsupported kernel architecture:/) }
  end

  context 'by default, location should be localhost' do
    it { should contain_file('consul-template config.json') \
      .with_content(/"consul":"localhost:8500"/) \
      .with(
        'ensure'  => 'present',
        'path'    => '/etc/consul-template/config/config.json'
      )
    }
  end

  context 'directories should be created' do
    it { should contain_file('/etc/consul-template').with(:ensure => 'directory') }
    it { should contain_file('/etc/consul-template/config').with(:ensure => 'directory') }
    it { should contain_file('/etc/consul-template/templates').with(:ensure => 'directory') }
  end

  context 'When not specifying whether to purge config' do
    it { should contain_file('/etc/consul-template').with(:purge => true,:recurse => true) }
    it { should contain_file('/etc/consul-template/templates').with(:purge => true,:recurse => true) }
  end

  context 'When passing a non-bool as purge_config_dir' do
    let(:params) {{
      :purge_config_dir => 'hello'
    }}
    it { expect { should compile }.to raise_error(/is not a boolean/) }
  end

  context 'When passing a non-bool as manage_service' do
    let(:params) {{
      :manage_service => 'hello'
    }}
    it { expect { should compile }.to raise_error(/is not a boolean/) }
  end

  context 'When disable config purging' do
    let(:params) {{
      :purge_config_dir => false
    }}
    it { should contain_class('consul_template::config').with(:purge => false) }
  end

  context 'consul_template::config should notify consul_template::service' do
    it { should contain_class('consul_template::config').that_notifies(['Class[consul_template::service]']) }
  end

  context 'consul_template::config should not notify consul_template::service on config change' do
    let(:params) {{
      :restart_on_change => false
    }}
    it { should_not contain_class('consul_template::config').that_notifies(['Class[consul_template::service]']) }
  end

  context 'When requesting to install via a package with defaults' do
    let(:params) {{
      :install_method => 'package'
    }}
    it { should contain_package('consul-template').with(:ensure => 'latest') }
  end

  context 'By default, a user and group should be installed' do
    it { should contain_user('consul-template').with(:ensure => :present) }
    it { should contain_group('consul-template').with(:ensure => :present) }
  end

  context 'By default, the service should be running and enabled' do
    it { should contain_service('consul-template').with(
      'ensure' => 'running',
      'enable' => true
    )}
  end

  context 'Unless darwin, install tar' do
    it { should contain_package('tar') }
  end

  context 'The max stale setting is set' do
    let(:params) {{
      :config_hash =>
        { 'max_stale' => '10m' }
    }}
    it { should contain_file('consul-template config.json').with_content(/"max_stale":"10m"/) }
  end

  context 'When asked not to manage the user' do
    let(:params) {{ :manage_user => false }}
    it { should_not contain_user('consul-template') }
  end

  context "When asked not to manage the group" do
    let(:params) {{ :manage_group => false }}
    it { should_not contain_group('consul-template') }
  end

  context "When asked not to manage the service" do
    let(:params) {{ :manage_service => false }}

    it { should_not contain_service('consul-template') }
  end

  context "With a custom username" do
    let(:params) {{
      :user => 'custom_consul_template_user',
      :group => 'custom_consul_template_group',
    }}
    it { should contain_user('custom_consul_template_user').with(:ensure => :present) }
    it { should contain_group('custom_consul_template_group').with(:ensure => :present) }
    it { should contain_file('/etc/init/consul-template.conf').with_content(/setuid custom_consul_template_user/) }
    it { should contain_file('/etc/init/consul-template.conf').with_content(/setgid custom_consul_template_group/) }
  end

  context "On a redhat 7 based OS" do
    let(:facts) {{
      :operatingsystem => 'CentOS',
      :operatingsystemmajrelease => '7'
    }}

    it { should contain_class('consul_template').with_init_style('systemd') }
    it { should contain_file('/lib/systemd/system/consul-template.service').with_content(/consul-template/) }
  end

  context "On an Amazon based OS" do
    let(:facts) {{
      :operatingsystem => 'Amazon',
      :operatingsystemrelease => '3.10.34-37.137.amzn1.x86_64'
    }}

    it { should contain_class('consul_template').with_init_style('sysv') }
    it { should contain_file('/etc/init.d/consul-template').with_content(/CONSUL_TEMPLATE=\/usr\/local\/bin\/consul-template/) }
  end

  context "When installing via URL by default" do
    it { should contain_class('consul_template::install') }
    it { should contain_class('staging') }
    it { should contain_class('staging::params') }
    it { should contain_staging__file('consul-template_0.11.0.zip').with(:source => 'https://releases.hashicorp.com/consul-template/0.11.0/consul-template_0.11.0_linux_amd64.zip') }
    it { should contain_file('/opt/staging/consul-template-0.11.0').with(:ensure => 'directory') }
    it { should contain_file('/opt/staging').with(:ensure => 'directory') }
    it { should contain_file('/opt/staging/consul_template').with(:ensure => 'directory') }
    it { should contain_file('/usr/local/bin/consul-template').that_notifies('Class[consul_template::service]') }
  end

  context "Specifying consul location" do
    let(:params) {{
      :config_hash =>
        { 'consul' => 'my.consul.service:8500' }
    }}
    it { should contain_file('consul-template config.json').with_content(/"consul":"my.consul.service:8500"/) }
  end

  
end

require 'spec_helper'


describe 'consul_template::watch', :type => :define do

  let(:title) { 'example' }

  context 'without a template' do
    let(:params) {{
      :destination => '/var/my_file',
    }}
    it { expect { should compile }.to raise_error(/Must pass template/) }
  end

  context 'without a destination' do
    let(:params) {{
      :template => 'consul_template_spec/test_template',
    }}
    it { expect { should compile }.to raise_error(/Must pass destination/) }
  end

  context 'create a template' do
    let(:params) {{
      :template    => 'consul_template_spec/test_template',
      :destination => '/var/my_file',
    }}
    it { should contain_file('/etc/consul-template/templates/example.ctmpl').with(:ensure => 'present') }
  end

  context 'standard config file' do
    let(:params) {{
      :template    => 'consul_template_spec/test_template',
      :destination => '/var/my_file', 
    }}
    it { should contain_file('/etc/consul-template/config/watch_example.json') \
      .with_content(/"source" *: *"\/etc\/consul-template\/templates\/example.ctmpl"/) \
      .with_content(/"destination" *: *"\/var\/my_file"/) 
    }
  end

  context 'with additional options' do
    let(:params) {{
      :template    => 'consul_template_spec/test_template',
      :destination => '/var/my_file',
      :command     => 'reload',
      :perms       => 777,
      :backup      => true,
    }}
    it { should contain_file('/etc/consul-template/config/watch_example.json') \
      .with_content(/"source" *: *"\/etc\/consul-template\/templates\/example.ctmpl"/) \
      .with_content(/"destination" *: *"\/var\/my_file"/) \
      .with_content(/"command" *: *"reload"/) \
      .with_content(/"perms" *: *777/) \
      .with_content(/"backup" *: *true/)
    }
  end

end

# require 'beaker-rspec'

# logger.error("LOADED MYYYYYYYYYY Spec Acceptance Helper")

# Install Puppet on all hosts
# install_puppet_agent_on(hosts, options)

# RSpec.configure do |c|
#   module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
# 
#   c.formatter = :documentation
# 
#   c.before :suite do
#     # Install module to all hosts
#     hosts.each do |host|
#       install_dev_puppet_module_on(host, :source => module_root, :module_name => 'elk',
#           :target_module_path => '/etc/puppetlabs/code/modules')
#     end
#   end
# end

default['clamav']['clamd']['enabled'] = true
default['clamav']['freshclam']['enabled'] = true

default['authorization']['sudo']['groups'] = ["wheel"]
default['authorization']['sudo']['passwordless'] = true

default['openssh']['server']['permit_root_login'] = "no"
default['openssh']['server']['password_authentication'] = "no"

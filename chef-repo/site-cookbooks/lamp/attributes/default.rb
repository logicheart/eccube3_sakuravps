default['httpd']['version'] = "2.2"
default['httpd']['docroot_dir'] = "/var/www/html"

default['php']['packages'] = ["php", "php-mbstring", "php-pear", "php-xml", "php-gd", "php-devel", "php-mysql", "php-mcrypt"]
default['php']['timezone'] = "Asia/Tokyo"

default['mysql']['version'] = "5.6"
default['mysql']['server_root_password'] = "password"

default['phpMyAdmin']['auth_file'] = "/var/www/.htpasswd"
default['phpMyAdmin']['user'] = "admin"
default['phpMyAdmin']['password'] = "phpMyAdmin"

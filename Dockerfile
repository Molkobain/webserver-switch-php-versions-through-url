# Use the official Ubuntu image
FROM ubuntu:24.04

# Supervisor (to supervise services)
# - Install necessary packages
RUN apt-get update && apt-get install -y \
    supervisor

# - Create configuration file
COPY conf-files/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Apache / PHP server
# - Install necessary packages for Apache
RUN apt-get install -y \
    apache2 \
    libapache2-mod-fcgid \
    software-properties-common \
    curl

# - Add PHP repository to retrieve multiple versions
RUN add-apt-repository ppa:ondrej/php && apt-get update

# - Install necessary packages for PHP versions and FPM
RUN apt-get install -y \
    php7.4 php7.4-fpm php7.4-mysql php7.4-apcu php7.4-curl php7.4-dom php7.4-gd php7.4-ldap php7.4-mbstring php7.4-soap php7.4-xdebug php7.4-xml php7.4-zip \
    php8.0 php8.0-fpm php8.0-mysql php8.0-apcu php8.0-curl php8.0-dom php8.0-gd php8.0-ldap php8.0-mbstring php8.0-soap php8.0-xdebug php8.0-xml php8.0-zip \
    php8.1 php8.1-fpm php8.1-mysql php8.1-apcu php8.1-curl php8.1-dom php8.1-gd php8.1-ldap php8.1-mbstring php8.1-soap php8.1-xdebug php8.1-xml php8.1-zip \
    php8.2 php8.2-fpm php8.2-mysql php8.2-apcu php8.2-curl php8.2-dom php8.2-gd php8.2-ldap php8.2-mbstring php8.2-soap php8.2-xdebug php8.2-xml php8.2-zip \
    php8.3 php8.3-fpm php8.3-mysql php8.3-apcu php8.3-curl php8.3-dom php8.3-gd php8.3-ldap php8.3-mbstring php8.3-soap php8.3-xdebug php8.3-xml php8.3-zip
    # IMPORTANT: If you add / remove PHP versions, mind to update the `conf-files/supervisor/supervisord.conf` accordingly

# - Enable Apache modules for FPM
RUN a2enmod actions fcgid alias proxy_fcgi
# - Enable Apache modules for PHP version depending on the URL
RUN a2enmod rewrite

# - Set up Virtual Hosts and switchable PHP versions
COPY conf-files/apache2/default-site.conf /etc/apache2/sites-available/000-default.conf
COPY conf-files/apache2/php-versions-through-url.conf /etc/apache2/conf-available/php-versions-through-url.conf

# - Set up custom PHP options
#   - 7.4
COPY conf-files/php/cli/* /etc/php/7.4/cli/conf.d/
COPY conf-files/php/fpm/* /etc/php/7.4/fpm/conf.d/
#   - 8.0
COPY conf-files/php/cli/* /etc/php/8.0/cli/conf.d/
COPY conf-files/php/fpm/* /etc/php/8.0/fpm/conf.d/
#   - 8.1
COPY conf-files/php/cli/* /etc/php/8.1/cli/conf.d/
COPY conf-files/php/fpm/* /etc/php/8.1/fpm/conf.d/
#   - 8.2
COPY conf-files/php/cli/* /etc/php/8.2/cli/conf.d/
COPY conf-files/php/fpm/* /etc/php/8.2/fpm/conf.d/
#   - 8.3
COPY conf-files/php/cli/* /etc/php/8.3/cli/conf.d/
COPY conf-files/php/fpm/* /etc/php/8.3/fpm/conf.d/

# SSH server
# - Install necessary packages for SSH server
RUN apt-get update && apt-get install -y \
    openssh-server

# - Prepare configuration
RUN mkdir /var/run/sshd  # Create directory required by SSH
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config  # Allow root login
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config  # Allow password authentication
RUN echo 'root:root' | chpasswd  # Set root password (use a secure password!)

# Expose services ports
EXPOSE 22 80

# Start Supervisor to manage services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]








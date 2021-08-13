#Based on dockerfile
#https://github.com/welaika/docker-wordmove

FROM ruby:2.7.4

COPY mount-ssh.sh /bin/mount-ssh.sh
RUN chmod +x /bin/mount-ssh.sh

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  openssh-server \
  curl \
  rsync \
  mariadb-client \
  lftp \
  lsb-release \
  apt-transport-https \
  ca-certificates \
  wget \
  sshpass \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
  && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
  && apt update && apt -y install php7.4-cli php7.4-mysql \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN gem install wordmove --version 5.2.1
RUN curl -o /usr/local/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x /usr/local/bin/wp

RUN gem install wordmove

WORKDIR /wordmove

RUN usermod -u 1000 www-data

ENTRYPOINT ["/bin/mount-ssh.sh"]

CMD ["/bin/bash", "-l"]
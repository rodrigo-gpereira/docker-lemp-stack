FROM mysql:8.0

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/my.cnf

CMD ["mysqld"]

EXPOSE 3306

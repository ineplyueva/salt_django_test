# Установка необходимых пакетов
apt_install:
  pkg.installed:
    - forceyes: True
    - pkgs:
      - python-pip
      - mariadb-server
      - libmysqlclient-dev
      - nginx
      - virtualenv
      - git
      - uwsgi
      - uwsgi-plugin-python
      - python-mysqldb

# Старт сервисов после установки
mysql:
  service:
    - running
    - enable: True
    - reload: True
    - require:
      - pkg: apt_install

nginx:
  service:
    - running
    - enable: True
    - reload: True
    - require:
      - pkg: apt_install
    - watch:                                           # reload nginx при изменениях virtual-host
      - file: /etc/nginx/sites-enabled/default
      - file: /etc/nginx/sites-available/journal.conf

uwsgi:
  service:
    - running
    - enable: True
    - require:
      - pkg: apt_install
    - watch:                                           # restart uwsgi при изменениях ini и новых коммитах в проекте
      - file: /etc/uwsgi/apps-available/journal.ini
      - file: /etc/uwsgi/apps-enabled/journal.ini
      - git: https://github.com/ineplyueva/journal.git

### Создание папки и git pull проекта, настройка виртуального окружения
/var/www/venv/:
  file.directory:
    - user: www-data 
    - group: www-data
    - mode: 775
    - makedirs: True

pull_repo:
  git.latest:
    - name: https://github.com/ineplyueva/journal.git
    - target: /var/www/venv/journal
    - require:
      - pkg: apt_install

/var/www/venv:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: /var/www/venv/journal/requirements.txt

### Создание файлов wsgi.ini и nginx vhost в соответствующих папках
/etc/uwsgi/apps-available/journal.ini:
  file.managed:
    - source: salt://salt_django_test/journal.ini
    - mode: 755

/etc/uwsgi/apps-enabled/journal.ini:
  file.symlink:
    - target: /etc/uwsgi/apps-available/journal.ini

/etc/nginx/sites-available/journal.conf:
  file.managed:
    - source: salt://salt_django_test/journal.conf
    - mode: 755

/etc/nginx/sites-enabled/default:
  file.symlink:
    - target: /etc/nginx/sites-available/journal.conf

### Создание бд, пользователя с привилегиями
mysql-root-user-remote:
  mysql_user.present:
    - name: journal
    - host: 'localhost'
    - password: journal
    - connection_user: root
    - connection_pass: ''
    - connection_charset: utf8
    - connection_host: 'localhost'
    - saltenv:
      - LC_ALL: "en_US.utf8"
    - require:
      - service: mysql

mysql-grants:
  mysql_grants.present:
    - name: journal
    #- grant: "select, update, insert, create"
    - grant: all privileges
    - database: 'journal.*'
    - user: journal
    - host: localhost
    - connection_host: localhost
    - connection_user: root
    - connection_pass: ''
    - connection_charset: utf8
    - require:
      - service: mysql
      - mysql_user: journal
      - mysql_database: journal

journal:
  mysql_database.present:
    - require:
      - service: mysql

### Синхронизация бд
setup_db:
  cmd.run:
    - name: source bin/activate; python journal/manage.py makemigrations --noinput; python journal/manage.py migrate --noinput
    - cwd: /var/www/venv/
    - onchanges:                                           
      - git: https://github.com/ineplyueva/journal.git


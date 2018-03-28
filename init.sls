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
  sevice:
    - name:
      - nginx
      - mysql
      - uwsgi
    - enable: True
    - reload: True
    - running

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
    - requirements: journal/requirements.txt

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

/etc/nginx/sites-enabled/journal.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/journal.conf

mysql-root-user-remote:
  mysql_user.present:
    - name: journal
    - host: '127.0.0.1'
    - password: journal_pass
    - connection_user: root
    - connection_pass: ''
    - connection_charset: utf8
    - connection_host: '127.0.0.1'
    - saltenv:
      - LC_ALL: "en_US.utf8"
#    - require:
#      - service: mysql


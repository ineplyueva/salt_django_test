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
  sevice:
    - name:
      - nginx
      - mysql
    - enable: True
    - reload: True
    - running

/home/ubuntu/venv:
  file.directory:
    - user: ubuntu 
    - group: ubuntu 
    - mode: 775
    - makedirs: True

pull_repo:
  git.latest:
    - name: https://github.com/ineplyueva/journal.git
    - target: /home/ubuntu/venv/
    - require:
      - pkg: git

requirements:
  pip.installed:
    - names:
      - django
      - mysql-python

mysql-root-user-remote:
  mysql_user.present:
    - name: {{ pillar['mysql']['server']['journal_user'] }}
    - host: '%'
    - password: {{ pillar['mysql']['server']['jounal_password'] }}
    - connection_user: root
    - connection_pass: {{ pillar['mysql']['server']['root_password'] }}
    - connection_charset: utf8
    - saltenv:
      - LC_ALL: "en_US.utf8"
    - require:
      - service: mysql

#journal:
#  cmd.run:
#    - name: |
#        cd /home/ubuntu/venv/ && git clone https://github.com/ineplyueva/journal.git && cd jounal && pip install -U -r requirements.txt

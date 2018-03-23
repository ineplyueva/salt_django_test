mariadb:
  server:
    rootpwd: ''
  databases:
    journal:
      name: jounal
  users:
    - name: jounal
      password: journal_pass
      host: localhost
  grants:
    - user: journal
      host: 127.0.0.1
      database: 'journal.*'
      grant: all privileges



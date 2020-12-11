include:
  - nodejs

install_npm_dependencies:
  npm.bootstrap:
    - name: /srv/app/aik-front

aik-ui.service:
  file.managed:
    - name: /etc/systemd/system/aik-front.service
    - source: /srv/app/Infra/conf_management/states/files/aik-front.service

/srv/app/aik-front/server.js:
  file.managed:
    - mode: 777

system-reload:
  cmd.run:
    - name: "sudo systemctl --system daemon-reload"
  service.running:
    - name: aik-front
    - reload: True
    - enable: True
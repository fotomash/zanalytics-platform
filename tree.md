README.md
app
backend
clean-mt5.sh
config
docker-compose.yml
ignored_Dockerfile
monitoring
root
tree.md

./app:
app.py
constants.py
lib.py
requirements.txt
routes
swagger.py

./app/routes:
data.py
error.py
health.py
history.py
order.py
position.py
symbol.py

./backend:
django
mt5

./backend/django:
Dockerfile
app
manage.py
requirements.txt

./backend/django/app:
__init__.py
asgi.py
celery.py
nexus
quant
settings.py
urls.py
utils
wsgi.py

./backend/django/app/nexus:
__init__.py
admin.py
apps.py
filters.py
migrations
models.py
serializers.py
tests.py
urls.py
views.py

./backend/django/app/nexus/migrations:
__init__.py

./backend/django/app/quant:
__init__.py
admin.py
algorithms
apps.py
indicators
management
migrations
models.py
tasks.py
tests.py
views.py

./backend/django/app/quant/algorithms:
close
mean_reversion

./backend/django/app/quant/algorithms/close:
close.py

./backend/django/app/quant/algorithms/mean_reversion:
config.py
entry.py
trailing.py

./backend/django/app/quant/indicators:
mean_reversion.py

./backend/django/app/quant/management:
commands

./backend/django/app/quant/management/commands:
run_algorithms.py

./backend/django/app/quant/migrations:
__init__.py

./backend/django/app/utils:
__init__.py
account.py
api
arithmetics.py
constants.py
db
market.py

./backend/django/app/utils/api:
__init__.py
data.py
error.py
order.py
positions.py
ticket.py

./backend/django/app/utils/db:
close.py
create.py
get.py
mutation.py

./backend/mt5:
Dockerfile
app
root
scripts

./backend/mt5/app:
app.py
constants.py
lib.py
requirements.txt
routes
swagger.py

./backend/mt5/app/routes:
data.py
error.py
health.py
history.py
order.py
position.py
symbol.py

./backend/mt5/root:
defaults

./backend/mt5/root/defaults:
autostart
menu.xml

./backend/mt5/scripts:
01-start.sh
01-test.sh
02-common.sh
03-install-mono.sh
04-install-mt5.sh
05-install-python.sh
06-install-libraries.sh
07-start-wine-flask.sh

./config:
Desktop
Documents
Downloads
Music
Pictures
Public
Templates
Videos
ssl
winetricks-test.log
winetricks.log
xterm.2025.07.11.20.29.44.svg
xterm.2025.07.11.20.29.45.svg
xterm.2025.07.11.20.44.42.svg

./config/Desktop:

./config/Documents:

./config/Downloads:

./config/Music:

./config/Pictures:

./config/Public:

./config/Templates:

./config/Videos:

./config/ssl:
cert.key
cert.pem

./monitoring:
README.md
assets
configs
dashboards

./monitoring/assets:
grafana-alert-state.png
grafana-alerting-detail.png
grafana-alerting-home.png
grafana-alerting-rules.png
grafana-container-metrics.png
grafana-dashboard.png
grafana-explore-logs.png
grafana-home.png
grafana-logs-search-dashboard.png
grafana-logs-view.png
uar-alert-view.png

./monitoring/configs:
alertmanager
grafana
loki
prometheus
promtail

./monitoring/configs/alertmanager:
alertmanager-email-config.yml
alertmanager-fallback-config.yml
alertmanager-opsgenie-config.yml
alertmanager-pushover-config.yml
alertmanager-slack-config.yml

./monitoring/configs/grafana:
plugins
provisioning

./monitoring/configs/grafana/plugins:
app.yaml

./monitoring/configs/grafana/provisioning:
dashboards.yml
datasources.yml

./monitoring/configs/loki:
loki.yaml
rules.yaml

./monitoring/configs/prometheus:
alerting-rules.yml
prometheus.yml
recording-rules.yml

./monitoring/configs/promtail:
promtail.yaml

./monitoring/dashboards:
alertmanager-dashboard.json
altertmanager-dashboard.json
container-metrics.json
log-search.json
node-metrics.json
traefik_official.json

./monitoring/dashboards/altertmanager-dashboard.json:

./root:
defaults

./root/defaults:
autostart
menu.xml

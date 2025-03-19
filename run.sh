#!/bin/bash
docker rm -f grafana

cat <<EOF > provisioning/datasources.yml
apiVersion: 1

datasources:
  - name: CloudWatch
    type: cloudwatch
    jsonData:
      authType: credentials
      defaultRegion: "$3"
      profile: "$2"

  - name: X-Ray
    type: grafana-x-ray-datasource
    jsonData:
      authType: credentials
      defaultRegion: "$3"
      profile: "$2"
EOF

docker run -d \
  -p 3000:3000 \
  -v "$(pwd)/grafana.ini:/etc/grafana/grafana.ini:ro" \
  -v "$(pwd)/provisioning:/etc/grafana/provisioning:ro" \
  -v "$(pwd)/dashboards:/var/lib/grafana/dashboards:ro" \
  -v "$1":/usr/share/grafana/.aws:ro \
  -e GF_INSTALL_PLUGINS=grafana-x-ray-datasource \
  --name grafana \
  grafana/grafana

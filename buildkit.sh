#!/usr/bin/env bash
set -e

export EDITOR=nano

curl -LO https://github.com/containerd/nerdctl/releases/download/v2.3.5/nerdctl-2.3.5-linux-amd64.tar.gz && tar -xzf nerdctl-2.3.5-linux-amd64.tar.gz && mv nerdctl /usr/local/bin/
curl -LO https://github.com/moby/buildkit/releases/download/v0.33.0/buildkit-v0.33.0.linux-amd64.tar.gz && tar -xzf buildkit-v0.33.0.linux-amd64.tar.gz && mv ./bin/buildctl ./bin/buildkitd /usr/local/bin/

cat <<'EOF' > /etc/systemd/system/buildkit.service
[Unit]
Description=BuildKit
Requires=buildkit.socket
After=buildkit.socket
Documentation=https://github.com/moby/buildkit

[Service]
Type=notify
ExecStart=/usr/local/bin/buildkitd --addr fd://

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' > /etc/systemd/system/buildkit.socket
[Unit]
Description=BuildKit
Documentation=https://github.com/moby/buildkit

[Socket]
ListenStream=%t/buildkit/buildkitd.sock
SocketMode=0660

[Install]
WantedBy=sockets.target
EOF

systemctl daemon-reload
systemctl enable --now buildkit.service
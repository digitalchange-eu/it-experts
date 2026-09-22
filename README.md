# Playbook Hands-On

## Übersicht

- Kubernetes Cluster mit 1 Control-plane (schedulable) und 1 Worker node (node01)
- Quellcode von Github auschecken und auf dem Worker node lokal einen Container damit bauen
- Headlamp im cluster installieren, um zu sehen was los ist
- Das gebaute Image im Cluster deployen und skalieren


## Detaillierter Ablauf

### A. Container Image lokal auf Worker node bauen

1) Auf https://killercoda.com anmelden - via Github oder Google Account, Alternativ via Email
2) Kubernetes Playground starten: https://killercoda.com/playgrounds/scenario/kubernetes, Hinweis: 60 min Timer startet
3) Default Einstiegspunkt ist Shell auf `controlplane`
4) Zweiten Tab öffnen und in Shell auf `node01` wechseln:
    ```bash
    ssh node01
    ```
    Ergebnis: Tab 2 zeigt nun `root@node01:~$`
5) In Tab 2 (`node01`) [nerdctl](https://github.com/containerd/nerdctl) und [BuildKit](https://github.com/moby/buildkit) installieren:
    ```bash
    curl -fsSL https://raw.githubusercontent.com/digitalchange-eu/it-experts/main/buildkit.sh | sudo bash
    ```
6) Code auschecken und in das Verzeichnis wechseln:
    ```bash
    git clone https://github.com/traefik/whoami.git && cd whoami
    ```
7) Container lokal bauen und in den lokalen Kubernetes container namespace (k8s.io) pushen:
    ```bash
    nerdctl -n k8s.io build -t localhost/whoami .
    ```

Ergebnis: Image `localhost/whoami` ist auf Worker `node01` verfügbar

### B. Kubernetes UI (Headlamp) installieren und verwenden

1) Auf die controlplane (Tab 1) wechseln
2) [Headlamp](https://headlamp.dev/) installieren. Admin wird ausgegeben:
    ```bash
    curl -fsSL https://raw.githubusercontent.com/digitalchange-eu/it-experts/main/headlamp.sh | bash
    ```
3) Prüfen ob Container läuft
4) Via nodePort mit Token auf Headlamp UI zugreifen

Ergebnis: Cluster kann in Headlamp "erforscht" werden

### C. Eigenes Image im Cluster deployen und skalieren

1) Cordon controlplane, da dort Image nicht verfügbar (sonst ErrImagePull)
2) `whoami` und Service via Kommandozeile deployen: `k create deployment whoami --image=localhost/whoami; k create service nodeport whoami --tcp=80:80`
3) Ereignisse in Headlamp verfolgen
4) Pod logs in Headlamp ansehen -> **Erkenntnis: Container läuft**
5) Via nodePort auf `whoami` zugreifen
6) Welche Hosts und IP-Adressen werden bei Browser-Reload angezeigt -> **Erkenntnis: Immer die selbe**
7) Deployment in Headlamp skalieren 1 -> 3
8) Via nodePort auf `whoami` zugreifen
9) Welche Hosts und IP-Adressen werden bei Browser-Reload angezeigt -> **Erkenntnis: Hosts und IP-Adressen rotieren = Demonstration des Loadbalancers**
10) Einzelne Pods in Headlamp löschen -> **Erkenntnis: Pods werden sofort ersetzt**
11) Via Tab 2 wieder auf `node01` wechseln und `htop` ausführen und nach `/whoami` suchen -> **Erkenntnis: Container sind einfach nur drei Linux-Prozesse**

Ergebnis: Hochverfügbare Bereitstellung eines selbstgebauten Container-Images
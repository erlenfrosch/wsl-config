```
╦ ╦╔═╗╦     ╔═╗╔═╗╔╗╔╔═╗╦╔═╗
║║║╚═╗║     ║  ║ ║║║║╠╣ ║║ ╦
╚╩╝╚═╝╩═╝   ╚═╝╚═╝╝╚╝╚  ╩╚═╝
```

<div align="center">

**Idempotentes Ansible-Playbook für eine vollständige WSL-Entwicklungsumgebung**

[![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat-square&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![Go](https://img.shields.io/badge/Go-00ADD8?style=flat-square&logo=go&logoColor=white)](https://golang.org/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![VS Code](https://img.shields.io/badge/VS%20Code-007ACC?style=flat-square&logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com/)

</div>

---

## Idee

Dieses Repo richtet mit einem einzigen Befehl eine vollständige WSL-Entwicklungsumgebung ein – reproduzierbar, versioniert und idempotent (mehrfaches Ausführen ist immer sicher).

Ein Bash-Bootstrap-Script installiert Ansible falls nötig und delegiert alles an ein Ansible-Playbook mit klar getrennten Rollen. Jede Rolle kann einzeln neu angefahren werden.

---

## Was wird eingerichtet?

| Bereich | Tools |
|---------|-------|
| **Basis** | `curl`, `git`, `build-essential`, `unzip`, `wget` |
| **Python** | pyenv + aktuelle stabile Python-Version |
| **Go** | goenv + aktuelle stabile Go-Version |
| **Kubernetes** | `kubectl`, `helm`, `k9s`, `kubectx`, `kubens`, `kustomize`, `flux`, `argocd` |
| **Terminal** | [Starship](https://starship.rs/) Prompt mit Git-, k8s-, Python- und Go-Segmenten |
| **VS Code** | WSL-Integration + Extensions für Python, Go und Kubernetes |

### VS Code Extensions

<details>
<summary>Alle installierten Extensions anzeigen</summary>

| Kategorie | Extension | Zweck |
|-----------|-----------|-------|
| WSL | `ms-vscode-remote.remote-wsl` | WSL-Integration |
| Python | `ms-python.python` | Core: IntelliSense, Debugging |
| | `ms-python.vscode-pylance` | Typ-Checking, schnelles IntelliSense |
| | `ms-python.black-formatter` | Code-Formatierung |
| | `ms-python.isort` | Import-Sortierung |
| | `charliermarsh.ruff` | Schneller Linter |
| | `ms-python.debugpy` | Python Debugger |
| | `ms-toolsai.jupyter` | Jupyter Notebooks |
| Go | `golang.go` | Offizielles Go-Plugin (gopls, delve) |
| Kubernetes | `ms-kubernetes-tools.vscode-kubernetes-tools` | Cluster-Explorer, kubectl |
| | `redhat.vscode-yaml` | YAML Language Server |
| | `ms-azuretools.vscode-docker` | Docker-Integration |
| | `tim-koehler.helm-intellisense` | Helm-Chart Autovervollständigung |
| | `mindaro-dev.mindaro` | Bridge to Kubernetes |
| DevOps | `hashicorp.terraform` | Terraform |
| | `github.vscode-github-actions` | GitHub Actions Workflows |
| | `eamodio.gitlens` | Erweitertes Git |
| Übersicht | `oderwat.indent-rainbow` | Farbige Einrückungsebenen |

</details>

---

## Voraussetzungen

- Windows mit WSL 2 (Ubuntu 26.04 empfohlen)
- [VS Code](https://code.visualstudio.com/) auf der **Windows-Seite** installiert
- `curl` in WSL verfügbar (in Ubuntu standardmäßig vorhanden)

---

## Ausführen

### Erstmalig – alles einrichten

```bash
git clone https://github.com/erlenfrosch/wsl-config.git ~/wsl-config
cd ~/wsl-config
./bootstrap.sh
```

Das Script installiert Ansible automatisch (falls noch nicht vorhanden) und führt danach das vollständige Playbook aus.

### Nur eine bestimmte Rolle ausführen

```bash
# Ansible muss bereits installiert sein
ansible-playbook -i inventory.ini site.yml --tags python
ansible-playbook -i inventory.ini site.yml --tags go
ansible-playbook -i inventory.ini site.yml --tags k8s
ansible-playbook -i inventory.ini site.yml --tags terminal
ansible-playbook -i inventory.ini site.yml --tags vscode
```

### Alles erneut ausführen (Idempotenz-Check)

```bash
./bootstrap.sh
# → Alle Tasks zeigen "ok", keine Fehler, keine unerwarteten Änderungen
```

---

## Repo-Struktur

```
wsl-config/
├── bootstrap.sh              # Einstiegspunkt: installiert Ansible, ruft site.yml auf
├── site.yml                  # Haupt-Playbook, bindet alle Rollen ein
├── inventory.ini             # Ansible-Inventory (localhost)
└── roles/
    ├── base/
    │   └── tasks/main.yml    # apt-Update + Basispakete
    ├── python/
    │   └── tasks/main.yml    # pyenv + Python
    ├── go/
    │   └── tasks/main.yml    # goenv + Go
    ├── k8s/
    │   └── tasks/
    │       ├── main.yml      # importiert alle Sub-Tasks
    │       ├── kubectl.yml
    │       ├── helm.yml
    │       ├── k9s.yml
    │       ├── kubectx.yml
    │       ├── kustomize.yml
    │       ├── flux.yml
    │       └── argocd.yml
    ├── terminal/
    │   ├── tasks/main.yml    # Starship installieren + konfigurieren
    │   └── files/
    │       └── starship.toml # Starship-Konfiguration
    └── vscode/
        └── tasks/main.yml    # WSL-Integration + Extensions
```

---

## Idempotenz

Jede Rolle ist so gebaut, dass sie beliebig oft ohne Nebenwirkungen ausgeführt werden kann:

- **apt-Module** sind von Haus aus idempotent
- **Version-Manager** nutzen `--skip-existing` bzw. `creates:`-Guards
- **Binaries** werden per `stat`-Check vor dem Download geprüft
- **`.bashrc`-Einträge** nutzen `lineinfile` mit `regexp` – keine Duplikate
- **VS Code Extensions** erkennen `"already installed"` im Output via `changed_when`

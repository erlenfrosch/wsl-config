# WSL Setup Script — Design Spec

**Date:** 2026-05-21  
**Status:** Approved

## Overview

Ein idempotentes Ansible-Playbook mit Bash-Bootstrap zum vollständigen Einrichten einer WSL-Entwicklungsumgebung auf Ubuntu 26.04. Das Playbook verwaltet alle benötigten Tools und die Terminal-Appearance in einem versionierten Repo.

## Repo-Struktur

```
wsl-config/
├── bootstrap.sh          # Einstiegspunkt: installiert Ansible, ruft site.yml auf
├── site.yml              # Haupt-Playbook, bindet alle Roles ein
├── roles/
│   ├── base/             # apt-Updates, Basispakete
│   ├── python/           # pyenv + aktuelle stabile Python-Version
│   ├── go/               # goenv + aktuelle stabile Go-Version
│   ├── k8s/              # kubectl, helm, k9s, kubectx, kubens, kustomize, flux, argocd
│   └── terminal/         # starship + starship.toml deployen
└── files/
    └── starship.toml     # versionierte Starship-Konfiguration
```

## Rollen

### `base`
- apt cache update + upgrade
- Basispakete: `curl`, `git`, `build-essential`, `unzip`, `wget`, `ca-certificates`
- Vollständig idempotent durch Ansible apt-Modul

### `python`
- pyenv via Git-Clone nach `~/.pyenv`
- Shell-Integration in `~/.bashrc` (via `lineinfile`, kein Duplicate)
- Neueste stabile Python-Version via `pyenv install --skip-existing` + `pyenv global`

### `go`
- goenv via Git-Clone nach `~/.goenv`
- Shell-Integration in `~/.bashrc` (via `lineinfile`, kein Duplicate)
- Neueste stabile Go-Version via `goenv install --skip-existing` + `goenv global`

### `k8s`
Jedes Tool in einer eigenen Task-Datei unter `roles/k8s/tasks/`:

| Tool | Installationsweg |
|------|-----------------|
| `kubectl` | apt (offizielle Kubernetes-Repo) |
| `helm` | offizielles Install-Script (Versionscheck) |
| `k9s` | GitHub Releases (Binary, prüft ob vorhanden) |
| `kubectx` / `kubens` | apt (Ubuntu-Repos) |
| `kustomize` | GitHub Releases (Binary, prüft ob vorhanden) |
| `flux` | GitHub Releases (Binary, prüft ob vorhanden) |
| `argocd` | GitHub Releases (Binary, prüft ob vorhanden) |

### `terminal`
- Starship via offizielles Install-Script (idempotent durch Versionscheck)
- `files/starship.toml` → `~/.config/starship.toml` via Ansible `copy`
- Starship-Initialisierung in `~/.bashrc` via `lineinfile`

## Starship-Konfiguration (`starship.toml`)

Aktive Module und ihr Zweck:

| Modul | Zeigt |
|-------|-------|
| `directory` | Aktuelles Verzeichnis (verkürzt) |
| `git_branch` | Aktueller Git-Branch |
| `git_status` | Unstaged / staged Changes (Symbole) |
| `kubernetes` | Cluster-Name + Namespace (nur wenn aktiver Context vorhanden) |
| `python` | Python-Version (nur in Python-Projekten) |
| `golang` | Go-Version (nur in Go-Projekten) |

## Idempotenz-Strategie

- **Ansible-nativ**: apt-, copy-, lineinfile-Module sind von Haus aus idempotent
- **Version-Manager**: `--skip-existing` Flag überspringt bereits installierte Versionen
- **Binaries**: `stat`-Check vor dem Herunterladen
- **bashrc-Einträge**: `lineinfile` mit `regexp` verhindert Duplikate
- **bootstrap.sh**: `which ansible` Prüfung vor der Installation

## Nutzung

```bash
# Erstmalig oder vollständig
./bootstrap.sh

# Nur eine spezifische Role nachfahren
ansible-playbook site.yml --tags python
ansible-playbook site.yml --tags k8s
ansible-playbook site.yml --tags terminal
```

## Abhängigkeiten

Keine externen Abhängigkeiten außer `apt` und `curl` — beides in Ubuntu standardmäßig vorhanden. Funktioniert auf einer frischen WSL-Instanz ohne Vorbereitung.

## Nicht im Scope

- Windows-seitige Konfiguration (Windows Terminal, etc.)
- Docker / container runtime
- IDE-Setup
- SSH-Key-Management

# dtadmin-vaultwarden

Vaultwarden für die DTAdmin-Vorlage **„Passwort-Tresor (Vaultwarden)“**: das offizielle Vaultwarden, gebaut aus dem
offiziellen Quelltext mit dem offiziellen `docker/Dockerfile.alpine`, plus **einem** Patch. Sonst nichts.

| Abbild | Vaultwarden | Patch |
|---|---|---|
| `ghcr.io/deltatree/dtadmin-vaultwarden:1.37.3-dt1` | [1.37.3](https://github.com/dani-garcia/vaultwarden/releases/tag/1.37.3) (Commit `eb212e23`) | `patches/0001-group-manage-stored-value.patch` |

## Warum der Patch

Vaultwarden 1.37.3 meldet für Gruppen mit dem Recht **„Einträge bearbeiten“** (`readOnly=false`,
`hidePasswords=false`, `manage=false`) zwei verschiedene Werte:

| Anfrage | `manage` |
|---|---|
| `GET /api/organizations/<org>/groups/<id>/details` | `false` (gespeicherter Wert) |
| `GET /api/organizations/<org>/collections/details` | `true` (abgeleitet aus `!readOnly && !hidePasswords`) |

Der Web-Tresor zeigt deshalb unter „Sammlung → Zugriff bearbeiten“ **„Sammlung verwalten“**. Wer dort speichert,
macht daraus wirklich `manage=true`: Die Gruppe darf danach Zugriffe auf die Sammlung vergeben.

Der Patch liefert in `CollectionGroup::to_json_details_for_group` den gespeicherten Wert. Die tatsächliche
Rechteprüfung ändert er nicht; sie las schon vorher den gespeicherten Wert (`/api/sync` meldet `manage=false`).

Upstream: siehe Abschnitt „Status bei Vaultwarden“. Sobald Vaultwarden den Fehler in einem Release behebt, nutzt die
Vorlage wieder das offizielle Abbild, und dieses Repository wird archiviert.

## Bauen

```sh
test/build.sh 1.37.3 1.37.3-dt1     # klont das Tag, prüft den Commit, wendet patches/ an, baut linux/amd64
test/test.sh dtadmin-vaultwarden:1.37.3-dt1
```

Der Workflow `.github/workflows/build.yml` macht dasselbe und lädt bei einem Tag `v1.37.3-dt1` nach ghcr.io hoch.

## Status bei Vaultwarden

- Fehlerbericht und Pull-Request: werden nachgetragen.

# ILIAS (TMS) Docker Images

Docker ermöglicht uns Ilias in eigenen Containern laufen zu lassen, ohne, dass ein lokales AMP-System aufgebaut werden muss. Docker selbst kümmert sich um alle Server-Einstellungen und Tools.

## Architektur

Der Aufbau der Architektur hinter Docker ist dabei möglichst modular gesetzt, sodass schnell und einfach zwischen verschiedenen ILIAS Versionen gewechselt werden kann, bzw. diese parallel laufen. Dafür werden verschiedene Container bereit gestellt, die zusätzlich individuell konfiguriert werden können.

* Ubuntu Webserver mit PHP 7.3 als System für Ilias
* MySQL 5.6 Server zum Betrieb der Datenbanken
* PHPMyAdmin Server

Grundsätzlich wird das Tool docker-composer genutzt, da hier das linking der verschiedenen Container extrem vereinfacht wird und wir nicht mit unnötig komplizierten Befehlen herum doktorn müssen.

## Aufbau der Konfiguration

Innerhalb des System gibt es mehrere Konfigurationsmöglichkeiten, jedoch sollte wenn nur eine angepasst werden, um den individuellen Bedürfnissen zu entsprechen. Dafür öffnen wir die docker-compose.yml und sehen die entsprechende Konfiguration der aktuellen Container.

```yaml
version: "3"
services:
    ilf:
        build:
            context: .
            dockerfile: ilias54.Dockerfile
        image: ubuntu/latest
        ports:
            - "8080:80"
        volumes:
            - ./ilias/ilias54:/var/www/html
            - ./data/ilias54:/var/data/ilias54
            - ./logs/ilias54/logs/:/var/log/ilias/logs
            - ./logs/ilias54/error/:/var/log/ilias/error
            - ./skins/devk54:/var/www/html/ilias54/Customizing/global/skin
        links:
            - db:db
        networks:
            - default
    ils:
        build:
            context: .
            dockerfile: ilias60.Dockerfile
        image: ubuntu/latest
        ports:
            - "8081:80"
        volumes:
            - ./ilias/ilias60:/var/www/html
            - ./data/ilias60:/var/data/ilias60
            - ./logs/ilias60/logs/:/var/log/ilias/logs
            - ./logs/ilias60/error/:/var/log/ilias/error
        links:
            - db:db
        networks:
            - default
    db:
        image: mysql:5.6
        ports:
            - "3306:3306"
        command: --default-authentication-plugin=mysql_native_password --max_allowed_packet=32505856
        environment:
            MYSQL_DATABASE: ilias54
            MYSQL_USER: ilias
            MYSQL_PASSWORD: gjeipgjerip30
            MYSQL_ROOT_PASSWORD: gjeipgjerip30
        volumes:
            - persistent:/var/lib/mysql
        networks:
            - default
    phpmyadmin:
        image: phpmyadmin/phpmyadmin
        links:
            - db:db
        ports:
            - 8000:80
        environment:
            MYSQL_USER: ilias
            MYSQL_PASSWORD: gjeipgjerip30
            MYSQL_ROOT_PASSWORD: gjeipgjerip30
volumes:
    persistent:
```

Für uns von Interesse sind lediglich die Einträge für die Ports. phpMyAdmin läuft auf dem Port 8000 und kann über localhost:8000 angsteuert werden. Der TMS Webserver ist über den Port 8080 erreichbar und kann darüber genutzt werden. Sollten andere Ports genutzt werden, müssen nur diese Werte ausgetauscht werden. Ilias 6.0 kann später über den Port 8081 erreicht werden.

Außerdem können die Passwörter für die Datenbank hier angepasst werden, wenn man denn möchte. Wichtig dabei ist: Einmal gesetzt, lassen diese sich nur schwerlich ändern, da die MySQL Volume persistent gesetzt ist, damit diese nicht bei jedem Boot neu gebaut werden muss.

## Installation

Um das System das erste mal zu starten, müssen zunächst ein paar Schritte erledigt werden, damit alles so läuft, wie es laufen soll. Wir starten hier mit einer blanken ILIAS Version.

### TMS und Plugins klonen

1. Mit der git-bash nach ./conf navigieren
2. `chmod a+x install-tms54.sh` ausführen
3. `./install-tms54.sh` eingeben

Nun ist TMS bereit für den Startup

### Maschinen starten

Innerhalb der Konsole wechseln wir in das Verzeichnis, in welchem die docker-compose.yml liegt. Dort starten wir das System einfach mit docker-compose(.exe) up -d. Der erste Build wird einige Zeit in Anspruch nehmen, da hier das gesamte System heruntergeladen, installiert und aufgebaut wird. Wir gönnen uns also einen Kaffee und bei Bedarf eine Zigarette. Ist der Prozess fertig, sollten die letzten Zeilen in etwa folgende sein:

```bash
Starting {$folder}_db_1 ... done
Starting {$folder}_phpmyadmin_1 ... done
Starting {$folder}_www_1      ... done
```

### Composer-Dependencies installieren

Leider gibt es für diesen Schritt noch keine Automatisierung. Damit ILIAS funktionieren soll, müssen wir aber noch die composer Daten aktualisieren. Dafür müssen wir uns auf den laufenden Webserver einloggen. Mit dem Befehl docker(.exe) ps können wir alle Maschinen sehen. Die Ausgabe sieht in etwa so aus:

```bash
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                    NAMES
5f3607ec65b9        ubuntu/latest           "/var/www/run-lamp.sh"   2 hours ago         Up 2 hours          0.0.0.0:8080->80/tcp     {$folder}_www_1
868ce9ec260b        phpmyadmin/phpmyadmin   "/docker-entrypoint.…"   6 days ago          Up 2 hours          0.0.0.0:8000->80/tcp     {$folder}_phpmyadmin_1
92aa1a3ba1da        mysql:5.6               "docker-entrypoint.s…"   6 days ago          Up 2 hours          0.0.0.0:3306->3306/tcp   {$folder}_db_1
```

Uns interessiert hier die `CONTAINER ID` der ubuntu/latest Maschine. Mit dem Befehl `docker(.exe) exec -i -t 5f3607ec65b9 /bin/bash` loggen wir uns in die entsprechende Maschine ein. Wir navigieren zu dem Ordner /var/www/html/ und sehen mit ls dort unsere drei ilias{$version} Ordner.

In jeder Ilias-Version müssen wir in den Ordner `/libs/composer` wechseln und dort den Befehl `composer install` ausführen. Damit werden alle Composer-Daten aktualisiert und ILIAS wird laufen.

### TMS installieren

Nun können wir wie gewohnt TMS installieren, indem wir im Browser einfach http://localhost:8080/setup/setup.php aufrufen.

#### IP des Datenbankservers finden

Bei der Installation selbst wird die Adresse des Datenbankservers abgefragt. Diese können wir leicht heraus finden. Mit dem Befehl `docker(.exe) network ls` lassen sich alle aktiven Netzwerke auflisten. Die Ausgabe kann abweichen, sieht aber meist so aus:

```bash
NETWORK ID          NAME                DRIVER              SCOPE
9cfbdf6abe44        bridge              bridge              local
3f7a0c4eee33        build_default       bridge              local
5555af810d5a        dwww_default        bridge              local
5cc4c34affe0        host                host                local
b7178dedfc1d        lamp_default        bridge              local
bd7b58532b9f        none                null                local
7f78b20fe897        php-test_default    bridge              local
```

Wir benötigen den Namen unseres Netzwerkes. Es lässt sich mit {$ordner}_default identifizieren. In diesem Fall ist es dwww_default mit der ID 5555af810d5a. Jetzt können wir mit dem Befehl `docker(.exe) network inspect 5555af810d5a` die Konfiguration des Netzwerkes einsehen. Die Ausgabe sieht in etwa so aus:

```json
[
    {
        "Name": "dwww_default",
        "Id": "5555af810d5a69e98bbe34ed2c336713736dc4cf29557a4094144ccdbda55ab4",
        "Created": "2019-10-01T09:54:06.526452509+02:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.21.0.0/16",
                    "Gateway": "172.21.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": true,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "5f3607ec65b9bdf3e4bb5859ebe01ec250b0416257fead0df808629d381e5234": {
                "Name": "dwww_www_1",
                "EndpointID": "4b73f6e30494af54da55cbbb5a889a865a11655ab71483ca7835440d06ec5474",
                "MacAddress": "02:42:ac:15:00:04",
                "IPv4Address": "172.21.0.4/16",
                "IPv6Address": ""
            },
            "868ce9ec260b278c3c83f9aa03c859dc8ac9aece82658a9c3871e067e3db2b38": {
                "Name": "dwww_phpmyadmin_1",
                "EndpointID": "590839fb9339a8d8b8af50458d579b9059e21bfcfcfedcf00bf9813dbd5fb803",
                "MacAddress": "02:42:ac:15:00:03",
                "IPv4Address": "172.21.0.3/16",
                "IPv6Address": ""
            },
            "92aa1a3ba1daa6fcd1d64ee5c1593aa7d23d137e110844639cd0340dc745c1f3": {
                "Name": "dwww_db_1",
                "EndpointID": "f4351c676540c94282ae59865d8698e159f2070bd9a42023c0fe13f53bf67b3d",
                "MacAddress": "02:42:ac:15:00:02",
                "IPv4Address": "172.21.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {
            "com.docker.compose.network": "default",
            "com.docker.compose.project": "dwww",
            "com.docker.compose.version": "1.24.1"
        }
    }
]
```

Wir interessieren uns nur für einen der untersten Einträge Containers. Dort finden wir die Maschine mit dem Namen {$folder}_db_1 mit der zugehörigen IP Adresse. In diesem Fall `172.21.0.2`.

### Plugins installieren

Nach der Installation müssen natürlich alle weiteren Plugins installiert und aktiviert werden.

## Wechseln der Skins

Es ist mit dieser Konfiguration sehr einfach die Skins innerhalb einer TMS-Installation zu wechseln. In der `docker-compose.yml` findet sich die Zeile `- ./skins/devk54:/var/www/html/ilias54/Customizing/global/skin`. Hier muss `devk54` einfach mit dem entsprechenden Skin ausgetauscht werden. Über `docker-compose(.exe) up -d` muss danach die Maschine neu initialisiert werden.

## Aktualisieren der Daten

Um mit aktuellen Testdaten zu arbeiten, existiert innerhalb des Ordners `conf` ein Script namens `update-data.sh`. Dieses muss über die Konsole innerhalb des laufenden Docker-Images der TMS Installation ausgeführt werden, damit sich die Datenbank und das Dateisystem aktualisiert wird.

Dafür müssen im Script die entsprechenden Konfigurationsvariablen geändert werden.

import subprocess
from time import sleep
from traceback import print_exc
import xbmcgui
import urllib.request


# Funktion zum Abrufen der SSIDs mithilfe von nmcli
def get_wifi_ssids():
    try:
        # Führe den nmcli-Befehl aus, um die WLAN-Netzwerke abzurufen
        subprocess.check_call(
            ["flatpak-spawn", "--host", "sudo", "nmcli", "device", "wifi", "rescan"]
        )
        sleep(5)

        output = subprocess.check_output(
            [
                "flatpak-spawn",
                "--host",
                "nmcli",
                "-t",
                "-f",
                "SSID",
                "device",
                "wifi",
                "list",
            ],
            universal_newlines=True,
        )

        # Teile die Ausgabe in Zeilen auf und erstelle eine Liste der SSIDs (aus Spalte 1)
        ssids = output.strip().split("\n")

        # Entferne eventuell führende oder abschließende Leerzeichen
        ssids = [ssid.strip() for ssid in ssids]

        return ssids
    except subprocess.CalledProcessError as e:
        print_exc()
        return []
    except Exception as e:
        print_exc()
        return []


# Öffne ein Begrüßungsfenster
dialog = xbmcgui.Dialog()
dialog.ok("BYTE4RR4Y", "Choose a network and enter the password!")

# SSIDs abrufen
ssids = get_wifi_ssids()

# Erstelle ein Fenster
window = xbmcgui.Window(10000)

# Erstelle eine Listeansicht für die SSIDs
list_items = [ssid for ssid in ssids]

# Zeige die Liste der SSIDs in einem eigenen Fenster an
list_dialog = xbmcgui.Dialog()
selected_index = list_dialog.select("Choose a network", list_items)

# Überprüfe die Benutzerauswahl
if selected_index >= 0:
    selected_ssid = ssids[selected_index]

    # Fordere den Benutzer zur Eingabe des Passworts auf
    password = list_dialog.input("Password for " + selected_ssid, "")

# Eingabe des Passworts behandeln
if password:
    list_dialog.notification(
        "Info", "SSID: {} Passwort: {}".format(selected_ssid, password)
    )
else:
    list_dialog.notification("Info", "Empty Password")

command = [
    "flatpak-spawn",
    "--host",
    "sudo",
    "nmcli",
    "device",
    "wifi",
    "connect",
    selected_ssid,
    "password",
    password,
]

subprocess.run(
    [
        "flatpak-spawn",
        "--host",
        "sudo",
        "nmcli",
        "connection",
        "delete",
        selected_ssid,
    ]
)

# Befehl ausführen
subprocess.check_call(command)


def check_internet_connection():
    try:
        urllib.request.urlopen("http://www.google.com", timeout=2)
        return True
    except urllib.error.URLError:
        return False


if check_internet_connection():
    list_dialog.notification("Info", "Connection established")
else:
    list_dialog.notification("Info", "Connection failed")

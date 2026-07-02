#!/bin/bash
# Ensure the KDE Plasma panel (menu bar) shows on EVERY screen, not just the
# primary. On a GPU-passthrough workstation the SPICE virtio output sits at the
# 0,0 origin (Plasma screen 0), so the single default panel lands there and is
# invisible on the physical HDMI/DP monitors. Add a standard bottom panel to any
# screen that lacks one. Idempotent (skips screens that already have a panel) —
# safe to run on every login and after a monitor hotplug. Installed as an XDG
# autostart entry (KDE phase 2) so it runs once the Plasma session is up.
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"

QDBUS=qdbus6
command -v qdbus6 >/dev/null 2>&1 || QDBUS=qdbus

# Readiness (synchronization primitive, not a fixed sleep): wait for plasmashell
# to claim its bus name, then confirm the scripting interface actually answers
# before driving it.
gdbus wait --session --timeout 120 org.kde.plasmashell >/dev/null 2>&1 || true
i=0
while [ "$i" -lt 60 ]; do
    "$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'screenCount' >/dev/null 2>&1 && break
    i=$((i + 1))
    sleep 1
done

exec "$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var have = {};
panels().forEach(function (p) { have[p.screen] = true; });
for (var s = 0; s < screenCount; s++) {
    if (have[s]) continue;
    var panel = new Panel;
    panel.screen = s;
    panel.location = "bottom";
    panel.height = Math.round(gridUnit * 2.2);
    panel.addWidget("org.kde.plasma.kickoff");
    panel.addWidget("org.kde.plasma.icontasks");
    panel.addWidget("org.kde.plasma.marginsseparator");
    panel.addWidget("org.kde.plasma.systemtray");
    panel.addWidget("org.kde.plasma.digitalclock");
}
'

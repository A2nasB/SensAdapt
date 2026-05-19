workspace.windowActivated.connect(function(client) {
    var rc = client ? (client.resourceClass || "") : "";
    var cap = client ? (client.caption || "") : "";
    var df  = client ? (client.desktopFileName || "") : "";
    try {
        callDBus("org.sensadapt.Switcher", "/org/sensadapt/Switcher", "org.sensadapt.Switcher", "Activate", rc, cap, df);
    } catch(e) {}
});

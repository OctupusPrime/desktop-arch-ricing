import QtQuick

QtObject {
    readonly property QtObject tray: QtObject {
        readonly property var iconSubs: {
            "chrome_status_icon_1": "root:/assets/images/discord-icon.png",
            "polychromatic-tray-applet": "root:/assets/images/synapse-icon.png",
            "spotify-client": "root:/assets/images/spotify-icon.png",
            "steam": "root:/assets/images/steam-icon.png",
            "TelegramDesktop": "root:/assets/images/telegram-icon.png"
        }
    }

    // TODO: move back all config that end user will can change to here like workspace icons
}

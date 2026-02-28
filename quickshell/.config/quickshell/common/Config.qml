import QtQuick

QtObject {
    id: configRoot

    readonly property QtObject tray: QtObject {
        readonly property var iconSubs: {
            "chrome_status_icon_1": "root:/assets/images/discord-icon.png",
            "polychromatic-tray-applet": "root:/assets/images/synapse-icon.png",
            "spotify-client": "root:/assets/images/spotify-icon.png",
            "steam": "root:/assets/images/steam-icon.png",
            "TelegramDesktop": "root:/assets/images/telegram-icon.png"
        }
    }

    readonly property QtObject workspaces: QtObject {
        readonly property var iconSubs: {
            10: "root:/assets/icons/earth.svg",
            11: "root:/assets/icons/music.svg",
            12: "root:/assets/icons/gamepad-2.svg"
        }
    }
}

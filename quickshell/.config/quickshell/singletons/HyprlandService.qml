pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Singleton {
    id: hyprlandService

    property string keyboardLang: "UNK"
    property bool copilotCliOpened: false
    property string copilotCliWindowId: ""

    Component.onCompleted: {
        keyboardLangProc.running = true;
    }

    function openCopilotCli(rect) {
        const cmd = `exec [move ${rect.x} ${rect.y}; size ${rect.width} ${rect.height};] kitty --class copilot-cli -o confirm_os_window_close=0 copilot`;

        Hyprland.dispatch(cmd);
        Hyprland.dispatch(`movecursor ${rect.x + 20} ${rect.y + rect.height - 20}`);
    }
    function closeCopilotCli() {
        Hyprland.dispatch("closewindow class:^(copilot-cli)$");
    }

    function _updateKeyboardLang(layoutString) {
        if (!layoutString) {
            keyboardLang = "UNK";
        } else {
            keyboardLang = layoutString.substring(0, 3).toUpperCase();
        }
    }

    Socket {
        id: hyprEventSocket
        path: Hyprland.eventSocketPath
        connected: true
        parser: SplitParser {
            onRead: msg => {
                const [eventName, eventValue] = msg.split(">>");

                switch (eventName) {
                case "activelayout":
                    const layoutParts = eventValue.split(",");
                    hyprlandService._updateKeyboardLang(layoutParts[1]);
                    break;
                case "openwindow":
                    const [openId, , openClass] = eventValue.split(",");
                    if (openClass === "copilot-cli") {
                        hyprlandService.copilotCliWindowId = openId;
                        hyprlandService.copilotCliOpened = true;
                    }
                    break;
                case "closewindow":
                    if (eventValue === hyprlandService.copilotCliWindowId) {
                        hyprlandService.copilotCliWindowId = "";
                        hyprlandService.copilotCliOpened = false;
                    }
                    break;
                }
            }
        }
    }

    Process {
        id: keyboardLangProc
        command: ["hyprctl", "devices"]

        stdout: StdioCollector {
            onStreamFinished: {
                const keyboardBlocks = text.split(/Keyboard at [^\n]+:\n/).slice(1);

                for (const block of keyboardBlocks) {
                    if (!block.includes('main: yes'))
                        continue;

                    const match = block.match(/active keymap:\s*([^\n]+)/);
                    hyprlandService._updateKeyboardLang(match ? match[1] : null);
                    break;
                }
            }
        }
    }
}

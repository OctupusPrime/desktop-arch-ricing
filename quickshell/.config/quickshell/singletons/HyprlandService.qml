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

  function openCopilotCli({x, y, width, height}) {
    Hyprland.dispatch(`exec [move ${x} ${y}; size ${width} ${height};] kitty --class copilot-cli -o confirm_os_window_close=0 copilot`);
    // Positions the cusor to bottom left of the terminal
    Hyprland.dispatch(`movecursor ${x + 20} ${y + height - 20}`)
  }

  function closeCopilotCli() {
    Hyprland.dispatch("closewindow class:^(copilot-cli)$");
  }
  
  Socket {
    path: Hyprland.eventSocketPath
    connected: true

    parser: SplitParser {
      onRead: msg => {
        const [eventName, eventValue] = msg.split(">>");

        switch (eventName) {
          case "activelayout":
            const [, klayout] = eventValue.split(",");

            if (!klayout)
              hyprlandService.keyboardLang = "UNK";
            else
              hyprlandService.keyboardLang = klayout.substring(0, 3).toUpperCase();
          break;
          case "openwindow":
            const [openWindowId,, openWindowClass] = eventValue.split(",");

            if (openWindowClass === "copilot-cli") {
              hyprlandService.copilotCliWindowId = openWindowId;
              hyprlandService.copilotCliOpened = true;
            }
          break;
          case "closewindow":
            const closeWindowId = eventValue;

            if (closeWindowId === hyprlandService.copilotCliWindowId) {
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
      onStreamFinished: () => {
        const keyboardBlocks = this.text.split(/Keyboard at [^\n]+:\n/).slice(1);

        for (const block of keyboardBlocks) {
          if (!block.includes('main: yes')) continue;

          const [, klayout] = block.match(/active keymap:\s*([^\n]+)/);

          if (!klayout)
            hyprlandService.keyboardLang = "UNK";
          else
            hyprlandService.keyboardLang = klayout.substring(0, 3).toUpperCase();

          break;
        }
      }
    }
  }

  Component.onCompleted: {
    keyboardLangProc.running = true;
  }
}
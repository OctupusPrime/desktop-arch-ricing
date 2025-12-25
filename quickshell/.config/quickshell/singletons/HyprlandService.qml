pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Singleton {
  property string keyboardLang: "UNK"
  property bool copilotCliOpened: false 
  property string copilotCliWindowId: ""
  
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
              keyboardLang = "UNK";
            else
              keyboardLang = klayout.substring(0, 3).toUpperCase();
          break;
          case "openwindow":
            const [openWindowId,, openWindowClass] = eventValue.split(",");

            if (openWindowClass === "copilot-cli") {
              copilotCliWindowId = openWindowId;
              copilotCliOpened = true;
            }
          break;
          case "closewindow":
            const closeWindowId = eventValue;

            if (closeWindowId === copilotCliWindowId) {
              copilotCliWindowId = "";
              copilotCliOpened = false;
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
            keyboardLang = "UNK";
          else
            keyboardLang = klayout.substring(0, 3).toUpperCase();

          break;
        }
      }
    }
  }

  Component.onCompleted: {
    keyboardLangProc.running = true;
  }
}
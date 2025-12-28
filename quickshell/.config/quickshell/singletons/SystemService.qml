pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  Process {
    id: systemProcess
  }

  function shutdown() {
    systemProcess.exec(["sh", "-c", "systemctl poweroff"]);
  }

  function restart() {
    systemProcess.exec(["sh", "-c", "systemctl reboot"]);
  }

  function sleep() {
    systemProcess.exec(["sh", "-c", "systemctl suspend"]);
  }
}
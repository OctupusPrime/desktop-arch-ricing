import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.components

MyDropdownMenu {
  id: dBusMenuRoot

  MyDropdownMenu.Trigger {
    MyIcon {
      source: "root:/assets/icons/boxes.svg"
    }
  }

  MyDropdownMenu.Content {
    ColumnLayout {
      Text {
        text: "DBus Menu"
      }
    }
  }
}
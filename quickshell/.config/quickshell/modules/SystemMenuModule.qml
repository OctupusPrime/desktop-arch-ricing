import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.components

MyDropdownMenu {
  id: systemMenuRoot

  MyDropdownMenu.Trigger {
    MyIcon {
      source: "root:/assets/icons/arch.svg"
    }
  }

  MyDropdownMenu.Content {
    ColumnLayout {
      Text {
        text: "System menu"
      }

      Button {
        text: "Close"
        onClicked: {
          systemMenuRoot.close();
        }
      }
    }
  }
}
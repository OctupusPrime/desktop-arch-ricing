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
        text: "00000000000000000000000000000000000 "
      }
      Text {
        text: "00000000000000000000000000000000000 "
      }
            Text {
        text: "00000000000000000000000000000000000 "
      }
            Text {
        text: "00000000000000000000000000000000000 "
      }
            Text {
        text: "00000000000000000000000000000000000 "
      }
    }
  }
}
import QtQuick

Item {
  id: checkboxRoot

  property bool checked: false
  property bool indeterminate: false

  width: 16
  height: 16

  Rectangle {
    id: checkboxBox

    anchors.fill: parent

    color: theme.input
    radius: 4
    border.color: theme.border
    border.width: 1

    MyIcon {
      id: checkboxIcon

      visible: false
      anchors.centerIn: parent
      
      source: "root:/assets/icons/check.svg"
      size: 12
    }
  }

  states: [
    State {
      name: "checked"
      when: checkboxRoot.checked && !checkboxRoot.indeterminate
      PropertyChanges {
        checkboxBox {
          color: theme.primary
          border.color: theme.primary
        }
        checkboxIcon {
          visible: true
          color: theme.primaryForeground
        }
      }
    },
    State {
      name: "indeterminate"
      when: checkboxRoot.indeterminate
      PropertyChanges {
        checkboxBox {
          color: theme.input
          border.color: theme.border
        }
        checkboxIcon {
          visible: true
          color: theme.primary
        }
      }
    }
  ]
}
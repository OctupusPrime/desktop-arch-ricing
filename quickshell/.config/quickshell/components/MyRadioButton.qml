import QtQuick

Item {
  id: radioButtonRoot
  
  property bool checked: false

  width: 16
  height: 16

  Rectangle {
    anchors.fill: parent

    color: theme.input
    radius: sizes.rounded.full
    border.color: theme.border
    border.width: 1

    Rectangle {
      id: radioButtonDot

      visible: false
      anchors.centerIn: parent

      width: 8
      height: 8

      color: theme.primary
      radius: sizes.rounded.full
    }
  }

  states: [
    State {
      name: "checked"
      when: radioButtonRoot.checked
      PropertyChanges {
        radioButtonDot {
          visible: true
        }
      }
    },
  ]
}
import Quickshell
import Quickshell.Hyprland
import QtQuick

Item {
  id: popoverRoot

  property bool showBackground: true;
  property bool opened: false;
  property bool _isExiting: false;

  signal terminated()

  function open() {
    popoverRoot.opened = true;
  }

  function close() {
    popoverRoot._isExiting = true;
  }

  function toggle() {
    if (popoverRoot.opened) popoverRoot.close();
    else popoverRoot.open();
  }

  function terminate() {
    popoverRoot.opened = false;
    popoverRoot._isExiting = false;
    popoverRoot.terminated();
  }

  component Trigger: Item {
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height
  }
  component Content: Item {
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height
  }
  component Background: BorderImage {
    anchors { fill: parent; margins: -40 }
    border { left: 60; top: 60; right: 60; bottom: 60 }

    source: "root:/assets/images/popover-shadow.png"

    Rectangle {
      anchors { fill: parent; margins: 40 }

      color: theme.popover
      radius: sizes.rounded.md
      border.color: theme.border
      border.width: 1
    }
  }


  default property list<QtObject> _items
  property Trigger _trigger: null
  property Content _content: null

  Component.onCompleted: {
    for (let i = 0; i < _items.length; i++) {
      if (_items[i] instanceof Trigger) _trigger = _items[i];
      else if (_items[i] instanceof Content) _content = _items[i];
    }
  }

  implicitWidth: _trigger ? _trigger.implicitWidth : 0
  implicitHeight: _trigger ? _trigger.implicitHeight : 0

  Item {
    id: triggerContainer
    anchors.fill: parent

    TapHandler {
      onTapped: popoverRoot.open();
    }

    Binding {
      target: popoverRoot._trigger
      property: "parent"
      value: triggerContainer
    }
  }

  LazyLoader {
    id: popupLoader
    active: popoverRoot.opened

    PopupWindow {
      visible: true

      anchor {
        window: panel
        edges: Edges.Bottom
        gravity: Edges.Top

        rect: {
          var { x } = popoverRoot.mapToItem(panel.contentItem, 0, 0);
          return Qt.rect(x, 0, popoverRoot.width, 0);
        }
      }

      // Offsets of shadow
      implicitWidth: contentContainer.implicitWidth + 40
      implicitHeight: contentContainer.implicitHeight + 18
      color: "transparent"

      Item {
        id: contentContainer
        anchors.centerIn: parent

        implicitWidth: popoverRoot._content ? popoverRoot._content.implicitWidth : 100
        implicitHeight: popoverRoot._content ? popoverRoot._content.implicitHeight : 100

        transformOrigin: Item.Bottom
        opacity: 0
        scale: 0.95

        states: [
          State {
            name: "visible"
            when: popoverRoot.opened && !popoverRoot._isExiting
            PropertyChanges {
              contentContainer { opacity: 1; scale: 1 }
            }
          },
          State {
            name: "hidden"
            when: popoverRoot._isExiting
            PropertyChanges {
              contentContainer { opacity: 0; scale: 0.95 }
            }
          }
        ]

        transitions: [
          Transition {
            from: "*"; to: "visible" // On Entry
            ParallelAnimation {
              NumberAnimation { property: "opacity"; duration: 200 }
              NumberAnimation { property: "scale"; duration: 250; easing.type: Easing.OutBack }
            }
          },
          Transition {
            from: "visible"; to: "hidden" // On Exit
            SequentialAnimation {
              ParallelAnimation {
                NumberAnimation { property: "opacity"; duration: 200 }
                NumberAnimation { property: "scale"; duration: 250; easing.type: Easing.OutCubic }
              }
              NumberAnimation { duration: 100 } // Pause to ensure smoothness
              ScriptAction { 
                script: popoverRoot.terminate();
              }
            }
          }
        ]

        Background {
          visible: popoverRoot.showBackground
        }

        Binding {
          target: popoverRoot._content
          property: "parent"
          value: contentContainer
        }
      }
    }
  }

  HyprlandFocusGrab {
    windows: [popupLoader.item]
    active: popoverRoot.opened && !popoverRoot._isExiting
    onCleared: popoverRoot.close();
  }
}
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick

Item {
  id: menuRoot
  property bool opened: false;
  property bool _isExiting: false;

  function open() {
    menuRoot.opened = true;
  }

  function close() {
    menuRoot._isExiting = true;
  }

  function toggle() {
    if (menuRoot.opened) {
      menuRoot.close();
    } else {
      menuRoot.open();
    }
  }

  function terminate() {
    menuRoot.opened = false;
    menuRoot._isExiting = false;
  }

  component Trigger: Item {
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height
  }
  component Content: Item {
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height
  }

  default property list<Item> _items
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
      onTapped: menuRoot.open();
    }

    Binding {
      target: menuRoot._trigger
      property: "parent"
      value: triggerContainer
    }
  }

  LazyLoader {
    id: popupLoader
    active: menuRoot.opened

    PopupWindow {
      visible: true

      anchor {
        item: triggerContainer
        edges: Edges.Top
        gravity: Edges.Top
      }

      implicitWidth: contentRect.implicitWidth + 2 // Without this +2, a 1px border appears on the right and bottom
      implicitHeight: contentRect.implicitHeight + 2
      color: "transparent"

      ClippingRectangle {
        id: contentRect

        implicitWidth: menuRoot._content ? menuRoot._content.implicitWidth : 100
        implicitHeight: menuRoot._content ? menuRoot._content.implicitHeight : 100
        color: "white"
        radius: 10

        transformOrigin: Item.Bottom
        opacity: 0
        scale: 0.95

        states: [
          State {
            name: "visible"
            when: menuRoot.opened && !menuRoot._isExiting
            PropertyChanges { target: contentRect; opacity: 1; scale: 1.0 }
          },
          State {
            name: "hidden"
            when: menuRoot._isExiting
            PropertyChanges { target: contentRect; opacity: 0; scale: 0.95 }
          }
        ]

        transitions: [
          Transition {
            from: ""; to: "visible" // On Entry
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
                script: menuRoot.terminate();
              }
            }
          }
        ]

        Binding {
          target: menuRoot._content
          property: "parent"
          value: contentRect
        }
      }
    }
  }

  HyprlandFocusGrab {
    windows: [popupLoader.item]
    active: menuRoot.opened && !menuRoot._isExiting
    onCleared: menuRoot.close();
  }
}
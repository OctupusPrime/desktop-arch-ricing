import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

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
        window: panel
        edges: Edges.Bottom
        gravity: Edges.Top

        rect: {
          var triggerPos = menuRoot.mapToItem(panel.contentItem, 0, 0);
          return Qt.rect(triggerPos.x, 12, menuRoot.width, 0); // 12p[x offset is offset for Hyprland panel
        }
      }

      implicitWidth: contentRect.implicitWidth + 42 // Without this +42, to display shadows properly
      implicitHeight: contentRect.implicitHeight + 42
      color: "transparent"

      Rectangle {
        id: contentRect
        anchors.centerIn: parent

        implicitWidth: menuRoot._content ? menuRoot._content.implicitWidth : 100
        implicitHeight: menuRoot._content ? menuRoot._content.implicitHeight : 100
        color: theme.popover
        radius: sizes.rounded.md
        border.color: theme.border
        border.width: 1

        layer.enabled: true
        layer.effect: MultiEffect {
          shadowEnabled: true
          shadowColor: "black"
          shadowBlur: 1 
          shadowOpacity: 0.3 
          shadowVerticalOffset: 4
          shadowHorizontalOffset: 0
        }

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
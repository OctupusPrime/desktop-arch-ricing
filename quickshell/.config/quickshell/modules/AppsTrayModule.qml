import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.components

MyPopover {
  id: appsTrayModuleRoot

  showBackground: false
  
  onTerminated: {
    menuStack.clear()
    activeAppId = ""
  }

  property real maxHeight: Screen.height * 0.4
  property alias menuStack: trayMenuStackView
  property string activeAppId: ""

  MyPopover.Trigger {
    MyIcon {
      source: "root:/assets/icons/boxes.svg"
    }
  }

  MyPopover.Content {
    ColumnLayout {      
      spacing: sizes.hyprlOffset

      StackView {
        id: trayMenuStackView

        width: 188
        implicitHeight: appsTrayModuleRoot.maxHeight

        MouseArea {
          anchors.fill: parent
          onPressed: appsTrayModuleRoot.close();
        }

        replaceEnter: null
        replaceExit: Transition {
          PropertyAnimation {
            property: "opacity"
            to: 0
            duration: 250
            easing.type: Easing.OutCubic
          }
        }
      }

      Item {
        property int margin: 4
        property int minSize: 32

        implicitWidth: Math.max(minSize, appsGridContainer.implicitWidth) + margin * 2
        implicitHeight: Math.max(minSize, appsGridContainer.implicitHeight) + margin * 2


        Layout.alignment: Qt.AlignCenter

        MyPopover.Background {}

        Grid {
          id: appsGridContainer
          anchors.fill: parent
          anchors.margins: parent.margin

          columns: Math.min(appsGridRepeater.count, 5)
          spacing: 4

          Repeater {
            id: appsGridRepeater

            model: SystemTray.items

            delegate: AppItem {
              required property SystemTrayItem modelData

              appId: modelData.id
              icon: modelData.icon
              active: appsTrayModuleRoot.activeAppId === modelData.id

              onClicked: {
                appsTrayModuleRoot.menuStack.replace(trayMenuFactory, {
                  modelData: modelData
                })
                appsTrayModuleRoot.activeAppId = modelData.id;
              }
            }
          }
        }
      }
    }
  }

  Component {
    id: trayMenuFactory

    ColumnLayout {
      id: trayMenuRoot

      required property SystemTrayItem modelData
      
      Item {
        id: trayMenuContainer

        Layout.alignment: Qt.AlignBottom
        Layout.fillWidth: true

        readonly property bool hasContent: traySubMenuStack.currentItem && traySubMenuStack.currentItem.implicitHeight > 0

        implicitHeight: hasContent ? traySubMenuStack.currentItem.implicitHeight : 0

        transformOrigin: Item.Bottom
        opacity: 0
        scale:  0.95

        states: [
          State {
            name: "visible"
            when: trayMenuContainer.hasContent
            PropertyChanges {
              trayMenuContainer { opacity: 1; scale: 1 }
            }
          }
        ]

        transitions: [
          Transition {
            from: "*"
            to: "visible"
            ParallelAnimation {
              NumberAnimation { property: "opacity"; duration: 200 }
              NumberAnimation { property: "scale"; duration: 250; easing.type: Easing.OutBack }
            }
          }
        ]

        MyPopover.Background {}

        MouseArea {
          anchors.fill: parent
        }

        StackView {
          id: traySubMenuStack

          anchors.fill: parent
          clip: true

          Component.onCompleted: {
            traySubMenuStack.push(traySubMenuFactory, {
              handle: trayMenuRoot.modelData.menu,
              isSubMenu: false
            })
          }
          Component.onDestruction: {
            traySubMenuStack.clear();
          }

          pushEnter: Transition {
            PropertyAction {
              property: "opacity"
              value: 1
            }
            PropertyAnimation {
              property: "x"
              from: traySubMenuStack.width
              to: 0
              duration: 250
              easing.type: Easing.OutCubic
            }
          }
          pushExit: Transition {
            PropertyAction {
              property: "opacity"
              value: 0
            }
            PropertyAnimation {
              property: "x"
              from: 0
              to: -traySubMenuStack.width
              duration: 250
              easing.type: Easing.OutCubic
            }
          }
          popEnter: Transition {
            PropertyAction {
              property: "opacity"
              value: 1
            }
            PropertyAnimation {
              property: "x"
              from: -trayMenuStackView.width
              to: 0
              duration: 250
              easing.type: Easing.OutCubic
            }
          }
          popExit: Transition {
            PropertyAction {
              property: "opacity"
              value: 0
            }
            PropertyAnimation {
              property: "x"
              from: 0
              to: trayMenuStackView.width
              duration: 250
              easing.type: Easing.OutCubic
            }
          }
        }
      }
    }
  }

  Component {
    id: traySubMenuFactory

    ListView {
      id: traySubMenuRoot

      required property QsMenuHandle handle
      property bool isSubMenu: true
      property int margin: 4

      layer.enabled: StackView.view ? StackView.view.busy : false
      layer.smooth: true 

      topMargin: margin
      bottomMargin: isSubMenu ? 48 : margin
      leftMargin: margin
      rightMargin: margin

      implicitHeight: {
        if (contentHeight === 0) return 0;

        const totalHeight = contentHeight + topMargin + bottomMargin;

        return Math.min(totalHeight, appsTrayModuleRoot.maxHeight);
      }

      QsMenuOpener {
        id: traySubMenuOpener
        menu: traySubMenuRoot.handle
      }

      ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
      }

      model: traySubMenuOpener.children

      delegate: DelegateChooser {
        role: "isSeparator"

        DelegateChoice {
          roleValue: true

          Item {
            width: traySubMenuRoot.width
            height: childrenRect.height

            MenuSeparator {
              width: parent.width
              x: -traySubMenuRoot.leftMargin
            }
          }
        }

        DelegateChoice {
          roleValue: false

          MenuItem {
            required property var modelData

            width: traySubMenuRoot.width - traySubMenuRoot.leftMargin - traySubMenuRoot.rightMargin
            
            text: modelData.text
            enabled: modelData.enabled
            hasChildren: modelData.hasChildren
            buttonType: modelData.buttonType
            checkState: modelData.checkState

            onClicked: {
              if (modelData.hasChildren) {
                traySubMenuRoot.StackView.view.push(traySubMenuFactory, {
                  handle: modelData,
                  isSubMenu: true
                })
                return;
              }

              modelData.triggered();

              if (modelData.buttonType === QsMenuButtonType.None)
                appsTrayModuleRoot.close();
            }
          }
        }
      }

      CloseSubMenuButton {
        visible: traySubMenuRoot.isSubMenu

        width: traySubMenuRoot.width
        anchors.bottom: parent.bottom
        z: 10

        onClicked: {
          traySubMenuRoot.StackView.view.pop()
        }
      }
    }
  }

  component AppItem: Rectangle {
    id: appItemRoot

    required property var appId
    property string icon
    property bool active

    signal clicked()

    width: 32
    height: 32

    color: appItemHover.hovered || active ? theme.accent : "transparent"
    radius: sizes.rounded.sm

    function getIconSource(id: string, pathname: string): string  {
      if (id in config.tray.iconSubs) {
        return Qt.resolvedUrl(config.tray.iconSubs[id]);
      }

      if (pathname.includes("?path=")) {
        const [name, path] = pathname.split("?path=");
        return Qt.resolvedUrl(`${path}/${name.slice(name.lastIndexOf("/") + 1)}`);
      }
      return pathname;
    }

    Image {
      id: appItemIcon

      width: 20
      height: 20
      anchors.centerIn: parent
      source: appItemRoot.getIconSource(appItemRoot.appId, appItemRoot.icon)
      sourceSize: Qt.size(20, 20)
    }

    HoverHandler {
      id: appItemHover
    }
    TapHandler {
      onTapped: appItemRoot.clicked();
    }
  }

  component MenuSeparator: Item {
    id: menuSeparatorRoot

    Layout.fillWidth: true
    height: 9

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      height: 1
      color: theme.border
    }
  }

  component MenuItem: WrapperRectangle {
    id: trayMenuItemRoot

    property string text: ""
    property bool enabled: true
    property bool hasChildren: false
    property var buttonType: QsMenuButtonType.None
    property var checkState: 0 // 0: unchecked, 1: partially checked, 2: checked

    signal clicked()

    Layout.fillWidth: true
    topMargin: 6
    bottomMargin: 6
    leftMargin: 8
    rightMargin: 8

    color: trayMenuItemHover.hovered ? theme.accent : "transparent"
    radius: sizes.rounded.sm
    opacity: enabled ? 1 : 0.5

    RowLayout {
      spacing: 6

      MyText {
        Layout.fillWidth: true

        text: trayMenuItemRoot.text
        fontSize: sizes.text.sm
        color: theme.popoverForeground
        wrapMode: Text.WordWrap
      }

      MyIcon {
        visible: trayMenuItemRoot.hasChildren
        source: "root:/assets/icons/chevron-right.svg"
        size: 16
      }

      MyCheckbox {
        visible: trayMenuItemRoot.buttonType === QsMenuButtonType.CheckBox
        checked: trayMenuItemRoot.checkState === 2
        indeterminate: trayMenuItemRoot.checkState === 1
      }

      MyRadioButton {
        visible: trayMenuItemRoot.buttonType === QsMenuButtonType.RadioButton
        checked: trayMenuItemRoot.checkState === 2
      }
    }

    HoverHandler {
      enabled: trayMenuItemRoot.enabled
      id: trayMenuItemHover
    }

    TapHandler {
      enabled: trayMenuItemRoot.enabled
      onTapped: trayMenuItemRoot.clicked();
    }
  }

  component CloseSubMenuButton: Item {
    id: closeSubMenuButtonRoot

    signal clicked()

    Layout.fillWidth: true
    height: 48

    Rectangle {
      anchors.fill: parent
      radius: sizes.rounded.md
      gradient: Gradient {
        GradientStop { position: 0; color: "transparent" }
        GradientStop { position: 1; color: theme.popover } 
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true 
      onWheel: wheel.accepted = true
    }

    Item {
      anchors.centerIn: parent

      implicitWidth: childrenRect.width
      implicitHeight: childrenRect.height

      MouseArea {
        anchors.fill: parent

        onClicked: closeSubMenuButtonRoot.clicked();
      }

      WrapperRectangle {
        topMargin: 6
        bottomMargin: 6
        leftMargin: 10
        rightMargin: 10 

        color: theme.secondary
        radius: sizes.rounded.full

        MyText {
          text: "Back"
          fontSize: sizes.text.sm
          color: theme.secondaryForeground
        }
      }
    }
  }
}
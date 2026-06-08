import QtQuick

Column {
    id: accordionRoot

    property string type: "single" // "single" | "multiple"
    property real contentPadding: 0

    default property list<QtObject> _items

    property list<Content> _accordionItems: {
        let items = [];
        let indexCounter = 0;
        for (let i = 0; i < _items.length; i++) {
            if (_items[i] instanceof Content && _items[i].visible) {
                _items[i]._accordion = accordionRoot;
                _items[i]._index = indexCounter++;
                items.push(_items[i]);
            }
        }
        return items;
    }

    function _onItemToggled(index) {
        for (let i = 0; i < _accordionItems.length; i++) {
            if (_accordionItems[i]._index === index) {
                if (_accordionItems[i].enabled) {
                    _accordionItems[i].expanded = !_accordionItems[i].expanded;
                }
            } else if (accordionRoot.type === "single") {
                _accordionItems[i].expanded = false;
            }
        }
    }

    function collapseAll() {
        for (let i = 0; i < _accordionItems.length; i++) {
            _accordionItems[i].expanded = false;
        }
    }

    component Content: QtObject {
        property MyAccordion _accordion: null
        property int _index: -1
        property bool expanded: false

        property bool visible: true
        property bool enabled: true

        property Component triggerDelegate: null
        property Component contentDelegate: null

        function toggle() {
            if (!_accordion || !enabled)
                return;
            _accordion._onItemToggled(_index);
        }
    }

    Repeater {
        model: accordionRoot._accordionItems
        delegate: Column {
            id: itemDelegate
            width: parent.width

            required property var modelData
            required property int index
            property bool isExpanded: modelData.expanded

            enabled: modelData.enabled
            opacity: enabled ? 1.0 : 0.4

            Rectangle {
                width: parent.width
                height: 1
                color: theme.border
                visible: itemDelegate.index > 0
            }

            Item {
                id: triggerContainer
                width: parent.width
                height: triggerLoader.implicitHeight + 20

                Loader {
                    id: triggerLoader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.leftMargin: accordionRoot.contentPadding
                    anchors.rightMargin: accordionRoot.contentPadding
                    sourceComponent: itemDelegate.modelData.triggerDelegate
                    property bool expanded: itemDelegate.isExpanded
                    property var item: itemDelegate.modelData
                }
            }

            Item {
                id: contentContainer
                width: parent.width
                height: itemDelegate.isExpanded ? contentLoader.implicitHeight + 10 : 0
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Loader {
                    id: contentLoader
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: accordionRoot.contentPadding
                    anchors.rightMargin: accordionRoot.contentPadding
                    sourceComponent: itemDelegate.modelData.contentDelegate
                    property bool expanded: itemDelegate.isExpanded
                    property var item: itemDelegate.modelData
                }
            }
        }
    }
}

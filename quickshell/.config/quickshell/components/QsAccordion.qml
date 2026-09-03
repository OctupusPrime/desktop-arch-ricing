import QtQuick

Column {
    id: accordionRoot

    property string type: "single" // "single" | "multiple"
    property real contentPadding: 0

    default property list<QtObject> _items

    readonly property list<Content> _accordionItems: {
        const items = [];

        for (const item of _items) {
            if (!(item instanceof Content) || !item.visible)
                continue;

            item._accordion = accordionRoot;
            items.push(item);
        }

        return items;
    }

    function _onItemToggled(item): void {
        for (const current of _accordionItems) {
            if (current === item) {
                if (current.enabled)
                    current.expanded = !current.expanded;
            } else if (accordionRoot.type === "single") {
                current.expanded = false;
            }
        }
    }

    function collapseAll(): void {
        for (const item of _accordionItems)
            item.expanded = false;
    }

    component Content: QtObject {
        id: contentRoot

        property QsAccordion _accordion: null

        property bool expanded: false
        property bool visible: true
        property bool enabled: true

        property Component trigger: null
        property Component content: null

        function toggle(): void {
            if (_accordion && enabled)
                _accordion._onItemToggled(contentRoot);
        }
    }

    Repeater {
        model: accordionRoot._accordionItems

        delegate: Column {
            id: itemDelegate

            required property var modelData
            required property int index

            readonly property bool isExpanded: modelData.expanded

            property bool contentActive: false

            width: accordionRoot.width
            enabled: modelData.enabled
            opacity: enabled ? 1 : 0.4

            Component.onCompleted: contentActive = isExpanded

            onIsExpandedChanged: {
                if (isExpanded)
                    contentActive = true;
                else if (contentLoader.status !== Loader.Ready)
                    contentActive = false;
            }

            Rectangle {
                width: itemDelegate.width
                height: 1

                visible: itemDelegate.index > 0
                color: theme.border
            }

            // TRIGGER
            Item {
                width: itemDelegate.width
                height: triggerLoader.implicitHeight + 20

                Loader {
                    id: triggerLoader

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right

                        topMargin: 10
                        leftMargin: accordionRoot.contentPadding
                        rightMargin: accordionRoot.contentPadding
                    }

                    sourceComponent: itemDelegate.modelData.trigger

                    property bool expanded: itemDelegate.isExpanded

                    property var item: itemDelegate.modelData
                }
            }

            // CONTENT
            Item {
                id: contentContainer

                width: itemDelegate.width

                height: itemDelegate.isExpanded && contentLoader.status === Loader.Ready ? contentLoader.implicitHeight + 10 : 0

                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic

                        onRunningChanged: {
                            if (!running && !itemDelegate.isExpanded)
                                itemDelegate.contentActive = false;
                        }
                    }
                }

                Loader {
                    id: contentLoader

                    anchors {
                        left: parent.left
                        right: parent.right

                        leftMargin: accordionRoot.contentPadding
                        rightMargin: accordionRoot.contentPadding
                    }

                    active: itemDelegate.contentActive
                    asynchronous: true
                    visible: status === Loader.Ready

                    sourceComponent: itemDelegate.modelData.content

                    property bool expanded: itemDelegate.isExpanded

                    property var item: itemDelegate.modelData
                }
            }
        }
    }
}

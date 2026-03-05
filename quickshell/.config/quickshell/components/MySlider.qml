import QtQuick
import QtQuick.Controls.Basic

Slider {
    id: sliderRoot

    background: Rectangle {
        x: sliderRoot.leftPadding
        y: sliderRoot.topPadding + sliderRoot.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: sliderRoot.availableWidth
        height: implicitHeight
        radius: 2
        color: theme.muted

        Rectangle {
            width: sliderRoot.visualPosition * parent.width
            height: parent.height
            radius: 2
            color: theme.primary
        }
    }

    handle: Rectangle {
        x: sliderRoot.leftPadding + sliderRoot.visualPosition * (sliderRoot.availableWidth - width)
        y: sliderRoot.topPadding + sliderRoot.availableHeight / 2 - height / 2
        implicitWidth: 12
        implicitHeight: 12
        radius: 6
        color: "white"
        border.width: 1
        border.color: theme.ring
    }
}

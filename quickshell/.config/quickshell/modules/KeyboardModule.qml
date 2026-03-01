import QtQuick

import qs.singletons
import qs.components

MyText {
    id: keyboardModuleRoot

    text: HyprlandService.keyboardLang
    font.pixelSize: 14
    font.weight: 600
}

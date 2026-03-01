import QtQuick

import qs.singletons
import qs.components

MyText {
    id: keyboardModuleRoot

    text: HyprlandService.keyboardLang
    font.pixelSize: sizes.text.sm
    font.weight: sizes.font.semibold
}

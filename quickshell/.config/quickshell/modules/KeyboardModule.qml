import QtQuick

import qs.singletons
import qs.components

MyText {
    id: keyboardModuleRoot

    text: HyprlandService.keyboardLang
    fontSize: 14
    fontWeight: 600
}

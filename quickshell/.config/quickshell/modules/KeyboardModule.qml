import QtQuick

import qs.singletons
import qs.components

MyText {
  text: HyprlandService.keyboardLang
  fontSize: 14
  fontWeight: 600
}
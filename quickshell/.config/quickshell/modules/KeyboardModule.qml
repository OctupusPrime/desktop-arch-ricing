import QtQuick

import qs.singletons
import qs.components

MyText {
  text: HyprlandService.keyboardLang
  fontSize: sizes.text.sm
  fontWeight: sizes.font.semibold
}
import QtQuick

import qs.singletons
import qs.components

MyText {
  id: keyboardModuleRoot

  text: HyprlandService.keyboardLang
  fontSize: sizes.text.sm
  fontWeight: sizes.font.semibold
}
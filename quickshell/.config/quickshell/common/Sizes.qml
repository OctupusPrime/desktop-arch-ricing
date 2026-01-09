import QtQuick

QtObject {
  id: sizesRoot

  readonly property int shellHeight: 44
  readonly property int hyprlOffset: 8

  readonly property QtObject text: QtObject {
    readonly property int xs: 12
    readonly property int sm: 14
    readonly property int base: 16
    readonly property int lg: 18
    readonly property int xl: 20
    readonly property int x2l: 24
    readonly property int x3l: 30
    readonly property int x4l: 36
  }

  readonly property QtObject font: QtObject {
    readonly property int thin: 100
    readonly property int extralight: 200
    readonly property int light: 300
    readonly property int normal: 400
    readonly property int medium: 500
    readonly property int semibold: 600
    readonly property int bold: 700
    readonly property int extrabold: 800
    readonly property int black: 900
  }

  readonly property QtObject rounded: QtObject {
    readonly property int none: 0
    readonly property int xs: 2
    readonly property int sm: 4
    readonly property int md: 6
    readonly property int lg: 8
    readonly property int xl: 12
    readonly property int x2l: 16
    readonly property int x3l: 24
    readonly property int x4l: 32
    readonly property int full: 10000
  }
}
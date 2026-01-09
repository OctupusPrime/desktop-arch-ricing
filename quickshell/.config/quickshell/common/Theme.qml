import QtQuick

Item {
  id: themeRoot

  property color background
  property color foreground
  property color card
  property color cardForeground
  property color popover
  property color popoverForeground
  property color primary
  property color primaryForeground
  property color secondary
  property color secondaryForeground
  property color muted
  property color mutedForeground
  property color accent
  property color accentForeground
  property color destructive
  property color destructiveForeground
  property color border
  property color input
  property color ring

  state: "light"

  states: [
    State {
      name: "light"
      PropertyChanges {
        themeRoot {
          background: "#bbffffff"
          foreground: "#0a0a0a"
          card: "#ffffff"
          cardForeground: "#0a0a0a"
          popover: "#ffffff"
          popoverForeground: "#0a0a0a"
          primary: "#171717"
          primaryForeground: "#fafafa"
          secondary: "#f5f5f5"
          secondaryForeground: "#171717"
          muted: "#f5f5f5"
          mutedForeground: "#737373"
          accent: "#f5f5f5"
          accentForeground: "#171717"
          destructive: "#82181a"
          destructiveForeground: "#fb2c36"
          border: "#e5e5e5"
          input: "#e5e5e5"
          ring: "#a1a1a1"
        }
      }
    },
    State {
      name: "dark"
      PropertyChanges {
        themeRoot {
          background: '#bb0a0a0a'
          foreground: "#fafafa"
          card: "#0a0a0a"
          cardForeground: "#fafafa"
          popover: "#0a0a0a"
          popoverForeground: "#fafafa"
          primary: "#fafafa"
          primaryForeground: "#171717"
          secondary: "#262626"
          secondaryForeground: "#fafafa"
          muted: "#262626"
          mutedForeground: "#a1a1a1"
          accent: "#262626"
          accentForeground: "#fafafa"
          destructive: "#82181a"
          destructiveForeground: "#fb2c36"
          border: "#262626"
          input: "#262626"
          ring: "#525252"
        }
      }
    }
  ]

  transitions: Transition {
    from: "*"; to: "*"
    ColorAnimation { duration: 250; easing.type: Easing.InOutQuad }
  }
}
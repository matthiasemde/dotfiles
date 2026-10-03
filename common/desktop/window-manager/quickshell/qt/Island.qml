import QtQuick
import "./Theme.js" as Theme

// -- Island --------------------------------------------------------------------
//
// Scalable state machine. Add a new layer by:
//   1. adding a child component with an id and
//      `opacity: activeLayer === "myLayer" ? 1 : 0`
//   2. adding its id to the activeContent switch
//   3. setting `activeLayer = "myLayer"` from whatever trigger you like
//
// Hover detection lives in shell.qml as a sibling overlay MouseArea that sets
// `island.hovered`. This keeps it out of Island's subtree so nothing inside
// can steal the hover event.

Rectangle {
    id: root

    // Set by shell.qml's sibling hover overlay.
    property bool hovered: false

    onHoveredChanged: {
        if (hovered) {
            exitTimer.stop()
            if (activeLayer === "clock")
                activeLayer = "menu"
        } else {
            exitTimer.restart()
        }
    }

    property string activeLayer: "clock"

    readonly property real padding: 8

    readonly property Item activeContent: {
        switch (activeLayer) {
            case "menu":    return menuLayer
            case "volume":  return volumeLayer
            case "palette": return paletteLayer
            default:        return clockLayer
        }
    }

    width:  Math.max(activeContent.implicitWidth  + 2 * padding, 120)
    height: activeContent.implicitHeight + 2 * padding
    radius: Math.min(height / 2, 18)

    Behavior on width  { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

    color: Theme.base01
    clip: true

    // Exit after 300 ms outside the island — long enough not to interrupt a
    // volume drag that strays slightly outside the island bounds.
    Timer {
        id: exitTimer
        interval: 300
        onTriggered: root.activeLayer = "clock"
    }

    // -- Clock layer -----------------------------------------------------------
    ClockLayer {
        id: clockLayer
        anchors.centerIn: parent
        opacity: root.activeLayer === "clock" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutSine } }
    }

    // -- Menu layer ------------------------------------------------------------
    MenuLayer {
        id: menuLayer
        anchors.centerIn: parent
        opacity: root.activeLayer === "menu" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutSine } }

        onLayerRequested: (name) => {
            exitTimer.stop()
            root.activeLayer = name
        }
    }

    // -- Volume layer ----------------------------------------------------------
    VolumeLayer {
        id: volumeLayer
        anchors.centerIn: parent
        opacity: root.activeLayer === "volume" ? 1 : 0
        enabled: root.activeLayer === "volume"
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutSine } }
    }

    // -- Palette layer ---------------------------------------------------------
    PaletteLayer {
        id: paletteLayer
        anchors.centerIn: parent
        opacity: root.activeLayer === "palette" ? 1 : 0
        enabled: root.activeLayer === "palette"
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutSine } }
    }
}

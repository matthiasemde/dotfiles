import QtQuick
import "./Theme.js" as Theme

// -- Island --------------------------------------------------------------------
//
// Scalable state machine: add a new layer by
//   1. adding a child component with an id, and
//      `opacity: activeLayer === "myLayer" ? 1 : 0`
//   2. adding its id to the activeContent switch
//   3. setting `activeLayer = "myLayer"` from whatever trigger you like
//
// Width and height are derived from each layer's implicitWidth/implicitHeight
// plus a shared padding — no per-layer dimension hardcoding needed.

Rectangle {
    id: root

    // -- Active layer ----------------------------------------------------------
    property string activeLayer: "clock"

    // -- Padding around the active layer's content ----------------------------
    // Tune this to change the island size without touching individual layers.
    readonly property real padding: 8

    // Points to whichever layer component is currently active so its implicit
    // size drives the island dimensions.  Add a new case here for each layer.
    readonly property Item activeContent: {
        switch (activeLayer) {
            case "palette": return paletteLayer
            default:        return clockLayer
        }
    }

    width:  Math.max(activeContent.implicitWidth  + 2 * padding, 120)
    height: activeContent.implicitHeight + 2 * padding

    // height / 2 gives a perfect pill at small sizes; cap keeps it a rounded
    // rect as the island grows.  Animates automatically because height does.
    radius: Math.min(height / 2, 18)

    // Smooth morphing for all shape changes — works for any state pair
    Behavior on width  { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

    color: Theme.base01
    clip: true

    // -- Hover detection -------------------------------------------------------
    // MouseArea is more reliable than HoverHandler in Quickshell layer-shell
    // windows. acceptedButtons: Qt.NoButton passes clicks through to anything
    // below.  The 80 ms exit timer prevents the island's shrinking edge from
    // briefly re-crossing the cursor and re-triggering expansion.
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true

        onEntered: {
            exitTimer.stop()
            root.activeLayer = "palette"
        }
        onExited: exitTimer.restart()
    }

    Timer {
        id: exitTimer
        interval: 80
        onTriggered: root.activeLayer = "clock"
    }

    // -- Clock layer -----------------------------------------------------------
    ClockLayer {
        id: clockLayer
        anchors.centerIn: parent
        opacity: root.activeLayer === "clock" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutSine } }
    }

    // -- Palette layer ---------------------------------------------------------
    PaletteLayer {
        id: paletteLayer
        anchors.centerIn: parent
        opacity: root.activeLayer === "palette" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutSine } }
    }
}

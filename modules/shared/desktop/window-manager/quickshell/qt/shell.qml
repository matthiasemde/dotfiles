import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    PanelWindow {
        id: panel

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 12 + island.height
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: 48

        // Restrict pointer input to the visible island only.
        mask: Region {
            Region {
                intersection: Intersection.Combine
                x: Math.floor(island.x)
                y: Math.floor(island.y)
                width: Math.ceil(island.width)
                height: Math.ceil(island.height)
            }
        }

        Island {
            id: island
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 12
        }

        // Hover overlay — declared AFTER Island so it sits above it in z-order
        // and receives hover events first.  Being a sibling (not a child) of
        // Island means nothing inside Island's subtree can steal hover from it.
        // acceptedButtons: Qt.NoButton lets all click events fall through to
        // Island's TapHandlers.
        MouseArea {
            x: island.x
            y: island.y
            width: island.width
            height: island.height
            hoverEnabled: true
            acceptedButtons: Qt.NoButton

            onEntered: island.hovered = true
            onExited:  island.hovered = false
        }
    }
}

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

        // Height tracks the animated island so the compositor always
        // reserves exactly the right amount of space at the top edge.
        implicitHeight: 12 + island.height
        color: "transparent"

        // Float above app windows without pushing them down.
        WlrLayershell.exclusiveZone: 48

        // Restrict pointer input to the visible island only so the
        // transparent remainder of the panel doesn't swallow events.
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
    }
}

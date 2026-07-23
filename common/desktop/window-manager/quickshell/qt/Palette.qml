import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "Theme.js" as Theme

FloatingWindow {
    implicitWidth: 420
    implicitHeight: 220

    GridLayout {
        anchors.fill: parent
        anchors.margins: 12

        columns: 4
        rowSpacing: 12
        columnSpacing: 12

        Repeater {
            model: [
                ["base00", Theme.base00],
                ["base01", Theme.base01],
                ["base02", Theme.base02],
                ["base03", Theme.base03],
                ["base04", Theme.base04],
                ["base05", Theme.base05],
                ["base06", Theme.base06],
                ["base07", Theme.base07],
                ["base08", Theme.base08],
                ["base09", Theme.base09],
                ["base0A", Theme.base0A],
                ["base0B", Theme.base0B],
                ["base0C", Theme.base0C],
                ["base0D", Theme.base0D],
                ["base0E", Theme.base0E],
                ["base0F", Theme.base0F]
            ]

            delegate: Column {
                spacing: 4

                Rectangle {
                    width: 80
                    height: 40
                    radius: 6

                    color: modelData[1]
                    border.width: 1
                    border.color: "black"
                }

                Label {
                    text: modelData[0]
                    horizontalAlignment: Text.AlignHCenter
                    width: 80
                }
            }
        }
    }
}

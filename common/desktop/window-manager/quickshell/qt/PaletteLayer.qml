import QtQuick
import "./Theme.js" as Theme

Grid {
    columns: 8
    rowSpacing: 8
    columnSpacing: 8

    Repeater {
        model: [
            { name: "base00", color: Theme.base00 },
            { name: "base01", color: Theme.base01 },
            { name: "base02", color: Theme.base02 },
            { name: "base03", color: Theme.base03 },
            { name: "base04", color: Theme.base04 },
            { name: "base05", color: Theme.base05 },
            { name: "base06", color: Theme.base06 },
            { name: "base07", color: Theme.base07 },
            { name: "base08", color: Theme.base08 },
            { name: "base09", color: Theme.base09 },
            { name: "base0A", color: Theme.base0A },
            { name: "base0B", color: Theme.base0B },
            { name: "base0C", color: Theme.base0C },
            { name: "base0D", color: Theme.base0D },
            { name: "base0E", color: Theme.base0E },
            { name: "base0F", color: Theme.base0F }
        ]
        delegate: Rectangle {
            width: 96; height: 56; radius: 6
            color: modelData.color
            border.width: 2
            border.color: Qt.rgba(0, 0, 0, 0.25)

            Text {
                anchors.centerIn: parent
                text: modelData.name
                color: Theme.base00
                font.pixelSize: 16
                font.weight: Font.Bold
            }
        }
    }
}

import QtQuick
import "./Theme.js" as Theme

// -- Menu layer ----------------------------------------------------------------
// Navigation hub. Add new destinations by appending to `menuItems`.

Item {
    id: root

    signal layerRequested(string name)

    readonly property var menuItems: [
        { label: "Volume",  layer: "volume"  },
        { label: "Palette", layer: "palette" },
    ]

    implicitWidth:  row.implicitWidth  + 24
    implicitHeight: row.implicitHeight + 20

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: root.menuItems
            delegate: Rectangle {
                implicitWidth:  btnLabel.implicitWidth + 28
                implicitHeight: 38
                radius: 10
                color: btnMa.containsMouse ? Theme.base03 : Theme.base02
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    id: btnLabel
                    anchors.centerIn: parent
                    text: modelData.label
                    color: Theme.base05
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: btnMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.layerRequested(modelData.layer)
                }
            }
        }
    }
}

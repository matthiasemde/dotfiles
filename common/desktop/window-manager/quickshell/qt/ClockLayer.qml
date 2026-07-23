import QtQuick
import "./Theme.js" as Theme

Item {
    implicitWidth:  timeText.implicitWidth
    implicitHeight: timeText.implicitHeight

    Text {
        id: timeText
        anchors.centerIn: parent

        color: Theme.base05
        font.pixelSize: 16
        font.weight: Font.Medium

        text: Qt.formatTime(new Date(), "HH:mm")

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: timeText.text = Qt.formatTime(new Date(), "HH:mm")
        }
    }
}

import QtQuick
import Quickshell.Services.Pipewire
import "./Theme.js" as Theme

// -- Volume layer --------------------------------------------------------------
// Mute toggle + volume slider for the active sink, plus a sink-switcher list.
// All interaction uses MouseArea for consistent event handling (no TapHandler
// mix, which competes with MouseArea in the same component in Qt6).

Item {
    id: root

    property var activeSink: Pipewire.defaultAudioSink

    readonly property bool ready: activeSink !== null && activeSink.audio !== null
    readonly property real vol:   ready ? activeSink.audio.volume : 0.0
    readonly property bool muted: ready ? activeSink.audio.muted  : false

    implicitWidth:  260
    implicitHeight: col.implicitHeight + 24

    Column {
        id: col
        anchors {
            top: parent.top; topMargin: 12
            left: parent.left; leftMargin: 16
            right: parent.right; rightMargin: 16
        }
        spacing: 10

        // -- Sink name label ---------------------------------------------------
        Text {
            width: parent.width
            text: root.activeSink
                  ? (root.activeSink.description
                     || root.activeSink.properties["application.name"]
                     || root.activeSink.name
                     || "Unknown sink")
                  : "No default sink"
            color: Theme.base04
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        // -- Volume row: mute toggle + slider + % ------------------------------
        Row {
            width: parent.width
            spacing: 10

            // Mute toggle button
            Rectangle {
                id: muteBtn
                width: 36; height: 36; radius: 10
                color: muteMa.containsMouse ? Theme.base03 : Theme.base02
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: root.muted ? "🔇" : "🔊"
                    font.pixelSize: 16
                }

                MouseArea {
                    id: muteMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: if (root.ready) root.activeSink.audio.muted = !root.muted
                }
            }

            // Slider
            Item {
                id: sliderItem
                width: parent.width - muteBtn.width - pctLabel.width - 2 * parent.spacing
                height: 36

                Rectangle {
                    id: track
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width; height: 6; radius: 3
                    color: Theme.base03

                    Rectangle {
                        width: Math.max(0, Math.min(1, root.vol)) * track.width
                        height: track.height; radius: track.radius
                        color: root.muted ? Theme.base04 : Theme.base0D
                        Behavior on width { NumberAnimation { duration: 60 } }
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed:         setVol(mouseX)
                    onPositionChanged: setVol(mouseX)

                    function setVol(x) {
                        if (root.ready)
                            root.activeSink.audio.volume =
                                Math.max(0.0, Math.min(1.0, x / width))
                    }
                }
            }

            // Percentage label
            Text {
                id: pctLabel
                width: 38
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                text: Math.round(Math.max(0, root.vol) * 100) + "%"
                color: Theme.base05
                font.pixelSize: 13
            }
        }

        // -- Divider -----------------------------------------------------------
        Rectangle {
            width: parent.width; height: 1
            color: Theme.base02
        }

        // -- Sink switcher list ------------------------------------------------
        Repeater {
            model: Pipewire.nodes

            delegate: Item {
                required property var modelData
                readonly property bool isSink:
                    modelData.audio !== null
                    && modelData.properties["media.class"] === "Audio/Sink"

                visible: isSink
                width:   col.width
                height:  isSink ? 36 : 0

                Rectangle {
                    anchors.fill: parent; radius: 8
                    color: {
                        if (root.activeSink !== null && root.activeSink.name === modelData.name)
                            return Theme.base02
                        if (sinkMa.containsMouse)
                            return Theme.base01
                        return "transparent"
                    }
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left;  leftMargin:  10
                            right: parent.right; rightMargin: 10
                        }
                        text: modelData.description
                              || modelData.properties["application.name"]
                              || modelData.name
                              || "Sink"
                        font.pixelSize: 12
                        color: root.activeSink !== null && root.activeSink.name === modelData.name
                               ? Theme.base05 : Theme.base04
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: sinkMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.activeSink = modelData
                    }
                }
            }
        }
    }
}

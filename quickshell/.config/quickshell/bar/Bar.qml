import Quickshell
import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Pipewire
import Quickshell.Hyprland

PanelWindow {
    id: bar
    property int fontSize: 15
    RowLayout {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        spacing: 8

        // Workspace
        Repeater {
            model: Hyprland.workspaces
            Text {
                text: modelData.id
                color: "#ebdbb2"
                font.pixelSize: bar.fontSize
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Clock
        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        Text {
            text: Qt.formatDateTime(clock.date, "h:mm AP")
            color: "#8ec07c"
            font.pixelSize: bar.fontSize
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 14
        spacing: 8

        // Volume
        Text {
            text: "   " + Math.round((Pipewire.defaultAudioSink?.audio?.volume ?? 0) * 100) + "%"
            color: "#fabd2f"
            font.pixelSize: bar.fontSize
        }
        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }
    }
}

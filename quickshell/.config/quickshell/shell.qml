import Quickshell
import QtQuick

import "./bar"

ShellRoot {
    Bar {
        anchors {
            top: true
            left: true
            right: true
        }
        color: "#1a1b26"
        implicitHeight: 40
    }
}

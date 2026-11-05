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
        color: "#1d2021"
        implicitHeight: 40
    }
}

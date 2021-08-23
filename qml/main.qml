import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 1920
    height: 1080
    visible: true
    title: qsTr("Hello World")

    Dashboard {
        id: theDashboard
        anchors.fill: parent
    }
}

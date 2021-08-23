import QtQuick 2.0
import QtQuick.Shapes 1.12

Rectangle {
    color: "#100f10"
    Shape {

        ShapePath {
            startX: 0; startY: 0

            strokeWidth: 3
            strokeColor: "#1c191c"
            capStyle: ShapePath.RoundCap

            fillColor: "#161317"

            PathLine { x: 0; y: speedGauge.y + (speedGauge.height / 2) }
            PathLine { x: rpmGauge.x + (rpmGauge.width / 2); y: speedGauge.y + (speedGauge.height / 2) }
            PathLine { x: speedGauge.x; y: rpmGauge.y + (rpmGauge.height / 2) }
            PathLine { x: speedGauge.x + speedGauge.width; y: fuelGauge.y + (fuelGauge.height / 2) }
            PathLine { x: parent.width - (rpmGauge.width / 2); y: speedGauge.y + (speedGauge.height / 2) }
            PathLine { x: parent.width; y: speedGauge.y + (speedGauge.height / 2) }
            PathLine { x: parent.width; y: 0 }
        }
    }

    Gauge {
        id: speedGauge

        value: 0
        minValue: 0
        maxValue: 200
        incValue: 10

        minValueAngle: -245
        maxValueAngle: 65

        pulseColor: "#338693"

        width: 0.33 * parent.width
        height: 0.66 * parent.height
        x: (parent.width - width) / 2
        y: 0
    }

    Gauge {
        id: rpmGauge

        value: 0
        minValue: 0
        maxValue: 11
        incValue: 1

        minValueAngle: 65
        maxValueAngle: minValueAngle + 180

        pulseColor: "#1ea951"

        width: 0.25 * parent.width
        height: 0.6 * parent.height
        x: 0
        y: parent.height - height
    }

    Gauge {
        id: fuelGauge
        value: 0
        minValue: 0
        maxValue: 110
        incValue: 10

        minValueAngle: 115
        maxValueAngle: minValueAngle - 180

        pulseColor: "#e12836"

        width: rpmGauge.width
        height: rpmGauge.height
        x: parent.width - width
        y: parent.height - height
    }

    Rectangle {
        id: statusBar
        color: "#1e1d1e"

        y: rpmGauge.y + (0.66 * rpmGauge.height)
        height: parent.height / 12
        anchors {
            left: rpmGauge.right
            right: fuelGauge.left
        }
    }
}

import QtQuick 2.12
import QtQuick.Shapes 1.12

Item {
    id: root

    // the current value of the Gauge
    property real value
    // the min value of the Gauge
    required property real minValue
    // the max value of the Gauge
    required property real maxValue
    // how much the value increases at each point on the gauge
    required property real incValue

    // the angle in degrees that the outer arc starts
    required property real minValueAngle
    // the angle in degrees that the outer arc ends
    required property real maxValueAngle
    // the sweep angle of the outer arc of the gauge
    readonly property real sweepAngle: maxValueAngle - minValueAngle
    // is the dial antiClockwise
    // defaults to clockwise
    property bool antiClockwise: false
    // whether or not the inner fillable arc is shown
    property bool showInnerArc: false

    // we want the gauge to always be circular regardless of ratio of width+height
    property real gaugeSize: getGaugeSize()
    // the size of the notches are 1% the size of the gauge with a min size of 5
    property real minNotchSize: 5
    property real notchSize: (gaugeSize * 0.01 > minNotchSize) ? gaugeSize * 0.01 : minNotchSize
    // the font size to draw the numbers with
    property real numberSize: gaugeSize * 0.04
    // the radius of the outer arc
    property real outerArcRadius: (gaugeSize * 0.85) / 2
    // the radius that the notches are drawn at
    property real notchRadius: (gaugeSize * 0.8) / 2
    // the radius that the number are drown at
    property real numberRadius:  (gaugeSize * 0.95) / 2
    // the radius of the innerCircle
    property real innerDiameter: gaugeSize / 2
    // the radius the pulse circle
    property real pulseDiameter: innerDiameter + (3 * notchSize)
    // the start and end radius of the needle
    property real needleStartRadius: (innerDiameter / 2) + (2 * notchSize)
    property real needleEndRadius: notchRadius - notchSize
    // inner arc information
    property real innerArcRadius: (notchRadius + (pulseDiameter / 2)) / 2 // lies halfway between the 2
    property real innerArcWidth: (notchRadius - (pulseDiameter / 2)) * 0.75 // 75% of the space between the 2

    // the number of notches on the dial
    property real numNotches: ((maxValue - minValue) / incValue) + 1
    property real anglePerNotch: sweepAngle / (numNotches - 1)

    // alias the pulse circle rectangle border
    property alias pulseColor: pulseCircle.border.color

    onWidthChanged: refreshGaugeSize()
    onHeightChanged: refreshGaugeSize()

    Behavior on value {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutBack
            easing.amplitude: 2
        }
    }

    Shape {
        ShapePath {
            id: outerArc

            strokeWidth: 3
            fillColor: "transparent"
            strokeColor: "white"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                // circular arc starting in the center with same size as the gauge
                centerX: width / 2
                centerY: height / 2
                radiusX: outerArcRadius
                radiusY: outerArcRadius

                startAngle: root.minValueAngle
                sweepAngle: root.sweepAngle
            }
        }
    }

    // notches + text indicators will be drawn with a repeater
    // we will draw a notch for each incValue that fits in minValue -> maxValue
    Repeater {
        id: notchRepeater

        model: numNotches

        // we have to calculate the positions of each of the notches - they will
        // be drawn slightly within the outerArc

        delegate: Rectangle {
            width: notchSize
            height: width
            radius: width
            color: "white"

            x: ((parent.width - width) / 2) + (notchRadius * Math.cos(getNotchAngleRadians(index)))
            y: ((parent.height - height) / 2) + (notchRadius * Math.sin(getNotchAngleRadians(index)))
        }
    }
    Repeater {
        id: textRepeater

        model: numNotches

        // we have to calculate the positions of each of the number - they will
        // be drawn slightly within the outerArc
        delegate: Text {
            property real notchAngleDegrees: getNotchAngle(index)
            property real notchAngleRadians: notchAngleDegrees * (Math.PI / 180);
            property real proximityValue: getNeedleProximity(notchAngleDegrees)

            font.family: "tahoma"
            font.pixelSize: numberSize * proximityValue

            color: (proximityValue > 1.0) ? root.pulseColor : "white"

            x: ((parent.width - width) / 2) + (numberRadius * Math.cos(notchAngleRadians))
            y: ((parent.height - height) / 2) + (numberRadius * Math.sin(notchAngleRadians))
            text: (index * incValue);

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
        }
    }

    // create our inner circle + pulse bit
    Rectangle {
        id: infoCircle

        anchors.centerIn: parent
        width: innerDiameter
        height: width
        radius: innerDiameter / 2

        color: "#242424"

        Rectangle {
            id: infoCircleSeparator

            height: 2
            width: parent.width * 0.9
            anchors.centerIn: parent
            color: "#2e2d2f"
        }

        Text {
            id: valueText
            text: value.toFixed(0)

            anchors {
                bottom: infoCircleSeparator.top
                bottomMargin: 8

                horizontalCenter: infoCircleSeparator.horizontalCenter
            }

            font.pixelSize: parent.height / 6
            font.family: "tahoma"
            color: "white"
        }
    }

    Shape {
        id: innerArc

        ShapePath {
            strokeColor: pulseColor
            strokeWidth: innerArcWidth
            capStyle: ShapePath.FlatCap
            fillColor: "transparent"

            PathAngleArc {
                // circular arc starting in the center with same size as the gauge
                centerX: width / 2
                centerY: height / 2
                radiusX: innerArcRadius
                radiusY: innerArcRadius

                startAngle: root.minValueAngle
                sweepAngle: (Math.min(Math.max(value, root.minValue), root.maxValue) - root.minValue) / (root.maxValue - root.minValue) * root.sweepAngle;

            }
        }
    }

    Shape {
        id: needle

        anchors.fill: parent

        property real centerX: parent.width / 2
        property real centerY: parent.height / 2
        property real needleAngle: getNeedleAngleRadians()
        property real needleAngleL: needleAngle - (Math.PI / 180)
        property real needleAngleR: needleAngle + (Math.PI / 180)

        ShapePath {
            fillColor: "#e12836"
            strokeWidth: 1
            capStyle: ShapePath.RoundCap
            strokeColor: fillColor

            // startX and startY will be the end of the needle
            // needs to be calculate based on the current value of the gauge
            startX: needle.centerX + (needleEndRadius * Math.cos(needle.needleAngle))
            startY: needle.centerY + (needleEndRadius * Math.sin(needle.needleAngle))

            PathLine {
                x: needle.centerX + (needleStartRadius * Math.cos(needle.needleAngleL))
                y: needle.centerY + (needleStartRadius * Math.sin(needle.needleAngleL))
            }
            PathLine {
                x: needle.centerX + (needleStartRadius * Math.cos(needle.needleAngleR))
                y: needle.centerY + (needleStartRadius * Math.sin(needle.needleAngleR))
            }
        }
        onWidthChanged: centerX = parent.width / 2
        onHeightChanged: centerY = parent.height / 2
    }

    Rectangle {
        id: pulseCircle

        anchors.centerIn: parent
        width: pulseDiameter
        height: width
        radius: width

        color: "transparent"
        border.width: notchSize
    }

    function refreshGaugeSize() {
        gaugeSize = getGaugeSize();
    }

    function getGaugeSize() {
        return (width < height) ? width : height;
    }

    function getNotchAngle(index)
    {
        return minValueAngle + (anglePerNotch * index);
    }

    function getNotchAngleRadians(index)
    {
        return getNotchAngle(index) * (Math.PI / 180);
    }

    function getNeedleAngle()
    {
        return minValueAngle + (Math.min(Math.max(value, minValue), maxValue) - minValue) / (maxValue - minValue) * sweepAngle;
    }

    function getNeedleAngleRadians() {
        return getNeedleAngle() * (Math.PI / 180);
    }

    function getNeedleProximity(angle)
    {
        var needleAngle = getNeedleAngle();

        var thresholdValue = Math.abs(anglePerNotch) * 0.25;
        var min = angle - thresholdValue;
        var max = angle + thresholdValue;

        var minOutput = 1.0;
        var maxOutput = 2.0

        var output = minOutput;
        if((needleAngle >= min) && (needleAngle <= angle))
        {
            // linear interp between min and angle
            output = ((maxOutput - minOutput) / (angle - min)) * (needleAngle - min) + minOutput;
        }
        else if((needleAngle >= angle) && (needleAngle <= max))
        {
            // linear interp between max and angle
            output = ((maxOutput - minOutput) / (angle - max)) * (needleAngle - max) + minOutput;
        }

        return output;
    }

    Timer {
        interval: 100;
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            value += 0.25; //Math.random() * 10;
        }
    }
}

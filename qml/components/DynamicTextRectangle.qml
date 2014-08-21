import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: dynRec
    property alias labelText: label.text
    property alias labelFontSize: label.font.pixelSize
    property alias labelColor: label.color
    color: "transparent"
    smooth: true
    border.width: 1
    border.color: Theme.secondaryHighlightColor
    radius: 5
    width: label.width + 20  // Add some space around text
    height: label.height + 5
    Label {
        id: label
        anchors.centerIn: parent
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.secondaryColor
        text: ""
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: statsRec
    property alias topLabelText: topLabel.text
    property alias topLabelFontColor: topLabel.color
    property int topLabelFontSize: Theme.fontSizeTiny
    property alias bottomLabelText: bottomLabel.text
    property alias bottomLabelFontColor: bottomLabel.color
    property int bottomLabelFontSize: Theme.fontSizeTiny
    // How much to increase or decrease (negative number) the height of regtangle to make topLabel and bottomLabel vertical distance from each other
    property int recHeightAdjustment: -5

    // Anchors selections left, right, center. Only one can be true.
    property bool anchorCenter: true
    property bool anchorRight: false
    property bool anchorLeft: false
    color: "transparent"
    smooth: true
    border.width: 0
    border.color: "gray"
    width: getWidth() + 20
    height: topLabel.height + bottomLabel.height + recHeightAdjustment
    radius: 10
    Label {
        id: topLabel
        anchors.top: parent.top
        font.pixelSize: topLabelFontSize
        anchors.horizontalCenter: anchorCenter ? parent.horizontalCenter : undefined
        anchors.right: anchorRight ? parent.right : undefined
        anchors.left: anchorLeft ? parent.left : undefined
    }
    Label {
        id: bottomLabel
        anchors.bottom: parent.bottom
        font.pixelSize: bottomLabelFontSize
        anchors.horizontalCenter: anchorCenter ? parent.horizontalCenter : undefined
        anchors.right: anchorRight ? parent.right : undefined
        anchors.left: anchorLeft ? parent.left : undefined
    }
    onAnchorCenterChanged: {
        if (anchorCenter) {
            anchorRight = false
            anchorLeft = false
        }
    }
    onAnchorRightChanged: {
        if (anchorRight) {
            anchorCenter = false
            anchorLeft = false
        }
    }
    onAnchorLeftChanged: {
        if (anchorLeft) {
            anchorCenter = false
            anchorRight = false
        }
    }
    function getWidth() {
        return topLabel.width > bottomLabel.width ? topLabel.width : bottomLabel.width
    }
}

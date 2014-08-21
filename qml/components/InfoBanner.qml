import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: infoBanner
    y: Theme.paddingSmall;
    z: 1;
    width: parent.width;

    height: infoLabel.height + 2 * Theme.paddingMedium;
    color: Theme.highlightBackgroundColor;
    opacity: 0;

    Label {
        id: infoLabel;
        text : ''
        font.pixelSize: Theme.fontSizeExtraSmall;
        width: parent.width - 2 * Theme.paddingSmall
        anchors.top: parent.top;
        anchors.topMargin: Theme.paddingMedium;
        y: Theme.paddingSmall;
        horizontalAlignment: Text.AlignHCenter;
        wrapMode: Text.WrapAnywhere;

        MouseArea {
            anchors.fill: parent;
            onClicked: {
                infoBanner.opacity = 0.0;
            }
        }
    }

    function visible() {
        return opacity > 0
    }

    function showText(text) {
        infoLabel.text = text;
        opacity = 0.9;
        closeTimer.restart();
    }

    Behavior on opacity { FadeAnimation {} }

    Timer {
        id: closeTimer;
        interval: 3000;
        onTriggered: infoBanner.opacity = 0.0;
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0
Item {
    anchors.left: ListView.left
    anchors.right: ListView.right
    width: ListView.view.width
    height: Theme.itemSizeSmall

    Column{
        anchors.fill: parent
        Label {
            font.pixelSize: Theme.fontSizeSmall
            text: title
        }

/*
        Label {
            text: "bar"
        }

        Label {
            text: "bas"
        }
        Label {
            text: "cap"
        }
*/
    }
    MouseArea
    {
        anchors.fill: parent
        onClicked: { siteURL = url; pageStack.push(Qt.resolvedUrl("WebView.qml")); }
    }
}

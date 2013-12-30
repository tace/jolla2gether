import QtQuick 2.0
import Sailfish.Silica 1.0
ListItem {
    anchors.left: ListView.left
    anchors.right: ListView.right
    width: ListView.view.width
//    height: Theme.itemSizeSmall
    contentHeight: Theme.itemSizeSmall
    onClicked: { siteURL = url; pageStack.navigateForward(); }

    Text {
        id: textTitle
        font.pixelSize: Theme.fontSizeMedium
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        width: parent.width
        color: Theme.primaryColor
        text: title
    }
    Text {
        id: textComment
        anchors.top: textTitle.bottom
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingSmall
//        width: 120
        text: "Answers "+answers
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.primaryColor
    }
}

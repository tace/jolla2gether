import QtQuick 2.0
import Sailfish.Silica 1.0
BackgroundItem  {
    anchors.left: ListView.left
    anchors.right: ListView.right
    width: ListView.view.width
    height: Theme.itemSizeSmall
    contentHeight: Theme.itemSizeSmall

    onClicked: { siteURL = url; pageStack.navigateForward(); }

    Column{
        anchors.fill: parent
        Label {
            font.pixelSize: Theme.fontSizeSmall
            color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
            text: title
        }
        Row {
            Label {
                font.pixelSize: Theme.fontSizeTiny
                text: author + "  "
            }
            Label {
                font.pixelSize: Theme.fontSizeTiny
                text: "Votes:" + votes + " "
            }
            Label {
                font.pixelSize: Theme.fontSizeTiny
                text: "Answers:" + answer_count + " "
            }
            Label {
                font.pixelSize: Theme.fontSizeTiny
                text: "Views:" + view_count + " "
            }
            Label {
                font.pixelSize: Theme.fontSizeTiny
                text: "Updated:" + updated + " "
            }
        }
    }
}

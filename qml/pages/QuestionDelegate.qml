import QtQuick 2.0
import Sailfish.Silica 1.0
BackgroundItem  {
    id: background
    anchors.left: ListView.left
    anchors.right: ListView.right
 //   width: ListView.view.width
    height: Theme.itemSizeSmall
    //x: Theme.paddingMedium
   // anchors.rightMargin: Theme.paddingMedium
    contentHeight: Theme.itemSizeSmall

    //onClicked: { siteURL = url; pageStack.navigateForward(); }
    onClicked: { siteURL = url; pageStack.push(Qt.resolvedUrl("WebView.qml")); }

    Column{
        anchors.fill: parent
        Label {
            font.pixelSize: Theme.fontSizeSmall
            color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
            text: title
        }
        Row {
            Label {
                id: authorLabel
                font.pixelSize: Theme.fontSizeTiny
                text: author + "  "
            }

            // Fill some space before statics rectangles
            Rectangle {
                id: fillRectangel
                color: "transparent"
                width: background.width - authorLabel.width - timesRectangle.width - votesRectangle.width - answersRectangle.width - viewsRectangle.width
                height: 40
            }

            // Created and updated time strings
            Rectangle {
                id: timesRectangle
                color: "transparent"
                width: 200
                height: 40
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.top: parent.top
                    anchors.right: parent.right
                    text: "c: " + created
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    text: "u: " + updated
                }
            }

            // Votes
            Rectangle {
                id: votesRectangle
                color: "transparent"
                smooth: true
                border.width: 1
                width: 60
                height: 40
                radius: 10
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    color: "lightgreen"
                    text: votes
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: "votes"
                }
            }

            // Answers
            Rectangle {
                id: answersRectangle
                color: "transparent"
                smooth: true
                border.width: 1
                width: 70
                height: 40
                radius: 10
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    color: "orange"
                    text: answer_count
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: "answers"
                }
            }

            // Views
            Rectangle {
                id: viewsRectangle
                color: "transparent"
                smooth: true
                border.width: 1
                width: 60
                height: 40
                radius: 10
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    color: "red"
                    text: view_count
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: "views"
                }
            }
        }
    }
}

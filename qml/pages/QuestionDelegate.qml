import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem  {
    id: background
    anchors.left: ListView.left
    anchors.right: ListView.right
    height: Theme.itemSizeSmall
    width: parent.width
    contentHeight: Theme.itemSizeSmall

    onClicked: {
        questionListView.currentIndex = index
        siteURL = url;
        pageStack.navigateForward();
    }

    function getTitleColor() {
        var color = Theme.primaryColor
        // If item selected either from list or Cover, make color highlighted
        if (background.highlighted ||
            (index === coverProxy.currentQuestion - 1)) {
            color = Theme.highlightColor
        }
        return color
    }
    Column{
        anchors.fill: parent
        Row {
            Label {
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.highlightColor
                anchors.verticalCenter: titleText.verticalCenter
                visible: closed
                text: "[closed] "
            }
            Label {
                id: titleText
                font.pixelSize: Theme.fontSizeSmall
                color: getTitleColor()
                font.bold: model.url === siteURL
                text: title
            }
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

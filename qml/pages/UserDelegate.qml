import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem  {
    id: background
    anchors.left: ListView.left
    anchors.right: ListView.right
    contentHeight: Theme.itemSizeSmall
    menu: contextMenu

    onClicked: { siteURL = url; pageStack.navigateForward(); }

    Column{
        anchors.fill: parent
        Row {
            Image {
                id: userPic
                width: 80
                height: 80
                source: "http:" + avatar
            }
            Label {
                id: userLabel
                font.pixelSize: Theme.fontSizeTiny
                color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.bold: model.url === siteURL
                text: " " + username
            }

            // Fill some space before statics rectangles
            Rectangle {
                id: fillRectangel
                color: "transparent"
                width: background.width - userPic.width - userLabel.width - karmaRectangle.width - timesRectangle.width
                height: 40
            }

            // Joined and last seen time strings
            Rectangle {
                id: timesRectangle
                color: "transparent"
                smooth: true
                //border.width: 1
                width: 235
                height: 40
                radius: 10
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.top: parent.top
                    anchors.right: parent.right
                    text: "joined: " + joined_at + "  "
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    text: "  seen: " + last_seen_at + "  "
                }
            }
            // Karma
            Rectangle {
                id: karmaRectangle
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
                    color: "lightgreen"
                    text: reputation
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: "karma"
                }
            }
        }
    }
    // context menu is activated with long press
    Component {
        id: contextMenu
        ContextMenu {
            MenuItem {
                text: qsTr("Copy url")
                onClicked: appClipboard.setClipboard(url)
            }
            MenuItem {
                text: qsTr("All " + username + "'s questions")
                onClicked: {
                    questionsModel.cacheModel()
                    questionsModel.setUserIdSearchCriteria(id)
                    questionsModel.pageHeader = username + "'s questions"
                    unattachWebview()
                    questionsModel.refresh()
                    pageStack.push(Qt.resolvedUrl("QuestionsPage.qml"), {userIdSearch: true})
                }
            }
        }
    }
}

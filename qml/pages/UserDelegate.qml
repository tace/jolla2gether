import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem  {
    id: background
    anchors.left: ListView.left
    anchors.right: ListView.right
    contentHeight: Theme.itemSizeLarge
    menu: contextMenu
    Keys.onReturnPressed: {
        clicked(MouseArea)
    }

    onClicked: {
        siteURL = url
        navigatedForward = true
        pageStack.navigateForward()
    }
    function getTitleColor() {
        var color = Theme.primaryColor
        // If item selected either from list or Cover, make color highlighted
        if (background.highlighted ||
            (usersListView.currentIndex === index)) {
            color = Theme.highlightColor
        }
        return color
    }

    Column{
        Row{
            id: imageRow
            Image {
                id: userPic
                width: 110
                height: 110
                source: usersModel.changeImageLinkSize(avatar_url, 110)
            }
            Label {
                id: userLabel
                font.pixelSize: Theme.fontSizeSmall
                color: getTitleColor()
                font.bold: model.url === siteURL
                text: " " + username
            }

            // Fill some space before statics rectangles
            Rectangle {
                id: fillRectangel
                color: "transparent"
                width: background.width - userPic.width - karmaRectangle.width - timesRectangle.width - userLabel.width
                height: 40
            }

            Column {
                Row {
                    Rectangle {
                        id: fillRectangel2
                        color: "transparent"
                        width: 1
                        height: 40
                    }
                }
                Row {
                    // Joined and last seen time strings
                    Rectangle {
                        id: timesRectangle
                        color: "transparent"
                        smooth: true
                        //border.width: 1
                        width: 250
                        height: 60
                        radius: 10
                        Label {
                            visible: joined_at !== undefined
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.top: parent.top
                            anchors.right: parent.right
                            text: "joined: " + joined_at + "  "
                        }
                        Label {
                            visible: joined_at !== undefined
                            font.pixelSize: Theme.fontSizeSmall
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
                        width: 85
                        height: 60
                        radius: 10
                        Label {
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            color: "lightgreen"
                            text: reputation
                        }
                        Label {
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            text: "karma"
                        }
                    }
                }
            }
        }
    }
    // context menu is activated with long press
    Component {
        id: contextMenu
        ContextMenu {
            MenuItem {
                text: qsTr("Copy url to clipboard")
                onClicked: Clipboard.text = url
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

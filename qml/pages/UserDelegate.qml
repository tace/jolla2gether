import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem  {
    id: background
    anchors.left: ListView.left
    anchors.right: ListView.right
    contentHeight: userPicSize
    property int userPicSize: pageSmallestSideLenght / 5
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

    Row {
        width: parent.width
        height: parent.height
        Image {
            id: userPic
            width: userPicSize
            height: userPicSize
            source: usersModel.changeImageLinkSize(avatar_url, userPicSize)
        }
        Column {
            width: parent.width - userPic.width
            Row {
                width: parent.width
                Label {
                    id: userLabel
                    font.pixelSize: Theme.fontSizeSmall
                    color: getTitleColor()
                    font.bold: model.url === siteURL
                    text: " " + username
                }
            }
            Row {
                width: parent.width
                // Fill some space before statics rectangles
                Item {
                    id: fillRectangel
                    width: parent.width - timesColumn.width - karmaRectangle.width
                    height: 1
                }
                // Joined and last seen time strings
                Column {
                    id: timesColumn
                    Label {
                        visible: joined_at !== undefined
                        font.pixelSize: Theme.fontSizeSmall
                        text: "joined: " + joined_at + "  "
                    }
                    Label {
                        visible: joined_at !== undefined
                        font.pixelSize: Theme.fontSizeSmall
                        text: "seen: " + last_seen_at + "  "
                    }
                }
                // Karma
                Rectangle {
                    id: karmaRectangle
                    color: "transparent"
                    smooth: true
                    border.width: 2
                    border.color: Theme.secondaryHighlightColor
                    width: karmaLabel.paintedWidth + 2 * Theme.paddingLarge
                    height: karmaLabel.paintedHeight + reputationLabel.paintedHeight
                    radius: 10
                    Column {
                        width: parent.width
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        Label {
                            id: reputationLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Theme.fontSizeSmall
                            color: "lightgreen"
                            text: reputation
                        }
                        Label {
                            id: karmaLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Theme.fontSizeSmall
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

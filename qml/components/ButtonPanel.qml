import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    width: parent.width

    Separator {
        width: parent.width
        horizontalAlignment: Qt.AlignCenter
        color: Theme.secondaryHighlightColor
        height: 2
    }
    Item {
        width: 1
        height: Theme.paddingSmall
    }
    Row {
        spacing: parent.width / (2 * 4 + 1)
        anchors.horizontalCenter: parent.horizontalCenter
        width: childrenRect.width
        height: childrenRect.height

        Column {
            visible: followedStatusLoaded
            width: childrenRect.width + Theme.paddingMedium
            Rectangle {
                width: searchButton.width - Theme.paddingMedium
                height: searchButton.height - Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                IconButton {
                    id: searchButton
                    anchors.centerIn: parent
                    icon.source: "image://theme/icon-m-search"
                    onClicked: {
                        searchBanner.show()
                    }
                }
            }
            Item {
                width: 1
                height: Theme.paddingSmall
            }
            Label {
                font.pixelSize: Theme.fontSizeTiny
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Search")
            }
        }
        Column {
            visible: followedStatusLoaded
            width: childrenRect.width + Theme.paddingMedium
            Rectangle {
                width: followedIcon.width - Theme.paddingMedium
                height: followedIcon.height - Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                IconButton {
                    id: followedIcon
                    anchors.centerIn: parent
                    icon.source: followed ? "image://theme/icon-m-favorite-selected"
                                          : "image://theme/icon-m-favorite"
                    enabled: ! infoBanner.visible()
                    onClicked: {
                        if (amILoggedIn(qsTr("Please log in to follow/un-follow questions!")))
                            followQuestion()
                    }
                }
            }
            Item {
                width: 1
                height: Theme.paddingSmall
            }
            Label {
                font.pixelSize: Theme.fontSizeTiny
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Follow")
            }
        }
        VoteButton {
            id: voteDownButton
            enabled: voteStatusLoaded
            visible: voteStatusLoaded
            buttonType: voteUpButton.question_vote_down
            userLoggedIn: questionsModel.isUserLoggedIn()
            userNotifObject: infoBanner
            oppositeVoteButton: voteUpButton
            initialVotes: votes
            votingTargetId: qid
        }
        VoteButton {
            id: voteUpButton
            enabled: voteStatusLoaded
            visible: voteStatusLoaded
            buttonType: voteUpButton.question_vote_up
            userLoggedIn: questionsModel.isUserLoggedIn()
            userNotifObject: infoBanner
            oppositeVoteButton: voteDownButton
            initialVotes: votes
            votingTargetId: qid
        }
    }
    Item {
        width: 1
        height: Theme.paddingSmall
    }
    Separator {
        width: parent.width
        horizontalAlignment: Qt.AlignCenter
        color: Theme.secondaryHighlightColor
        height: 2
    }
    function setVoteStatuses(up, down) {
        voteDownButton.setVoteStatus(down)
        voteUpButton.setVoteStatus(up)
    }
}

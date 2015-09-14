import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: buttonPanel
    width: parent.width
    property alias customButton1: customButton1
    property alias customButtom1LabelText: customButton1Label.text
    property alias customButton2: customButton2
    property alias customButtom2LabelText: customButton2Label.text

    property string voteButtonsTargetId
    property alias voteDownButton: voteDownButton
    property alias voteUpButton: voteUpButton
    property string voteButttonsInitialVote
    property bool isMyOwnPost: false  // Own question or answer

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
        height: childrenRect.height
        spacing: parent.width / (4 * (isLandscape ? 2 : 3)) + (isLandscape ? 10 : 7)
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            Rectangle {
                width: customButton1.width - Theme.paddingMedium
                height: customButton1.height - Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                IconButton {
                    id: customButton1
                    anchors.centerIn: parent
                    icon.source: ""
                }
            }
            Item {
                width: 1
                height: Theme.paddingSmall
            }
            Label {
                id: customButton1Label
                font.pixelSize: Theme.fontSizeTiny
                anchors.horizontalCenter: parent.horizontalCenter
                text: ""
            }
        }
        Column {
            Rectangle {
                width: customButton2.width - Theme.paddingMedium
                height: customButton2.height - Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                IconButton {
                    id: customButton2
                    anchors.centerIn: parent
                    icon.source: ""
                }
            }
            Item {
                width: 1
                height: Theme.paddingSmall
            }
            Label {
                id: customButton2Label
                font.pixelSize: Theme.fontSizeTiny
                anchors.horizontalCenter: parent.horizontalCenter
                text: ""
            }
        }
        VoteButton {
            id: voteDownButton
            buttonType: voteUpButton.question_vote_down
            userLoggedIn: questionsModel.isUserLoggedIn()
            userNotifObject: infoBanner
            oppositeVoteButton: voteUpButton
            initialVotes: voteButttonsInitialVote
            votingTargetId: voteButtonsTargetId
            isMyOwnPost: buttonPanel.isMyOwnPost
        }
        VoteButton {
            id: voteUpButton
            buttonType: voteUpButton.question_vote_up
            userLoggedIn: questionsModel.isUserLoggedIn()
            userNotifObject: infoBanner
            oppositeVoteButton: voteDownButton
            initialVotes: voteButttonsInitialVote
            votingTargetId: voteButtonsTargetId
            isMyOwnPost: buttonPanel.isMyOwnPost
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

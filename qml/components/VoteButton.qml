import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    property int question_vote_up: 1
    property int question_vote_down: 2
    property int answer_vote_up: 3
    property int answer_vote_down: 4
    property int buttonType: question_vote_up
    property alias buttonLabelText: voteButtonLabel.text

    property bool voteOn: false
    property string initialVotes
    property string votingTargetId
    property bool userLoggedIn: true
    property var userNotifObject: null
    property var webViewPage: pageStack.nextPage()
    property var oppositeVoteButton: null // to set status of e.g. down vote button if this is up button
    signal voted()

    property string voteDownButtonImage: "image://theme/icon-m-down"
    property string voteUpButtonImage: "image://theme/icon-m-up"

    Rectangle {
        id: statusRegtangle
        width: voteButton.width - Theme.paddingMedium
        height: voteButton.height - Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        border.color: getVotedStatusColor()
        border.width: voteButton.width / 10
        radius: voteButton.width / 2
        smooth: true
        IconButton {
            id: voteButton
            icon.source: getVoteButtonImage()
            anchors.centerIn: parent
            onClicked: {
                if (userLoggedIn) {
                    if (!voteOn) {
                        console.log("Voting " + (isUpOrDownButton() ? "UP" : "DOWN"))
                        vote(votingTargetId)
                    }
                    else {
                        if (userNotifObject !== null) {
                            var msg = "";
                            if (isUpOrDownButton())
                                msg = qsTr("Already voted up!")
                            else
                                msg = qsTr("Already voted down!")
                            userNotifObject.showText(msg)
                        }
                    }
                }
                else {
                    if (userNotifObject !== null)
                        userNotifObject.showText(qsTr("Please log in to vote!"))
                }
            }
        }
    }
    Item {
        visible: voteButtonLabel.visible
        width: 1
        height: Theme.paddingSmall
    }
    Label {
        id: voteButtonLabel
        visible: text !== ""
        font.pixelSize: Theme.fontSizeTiny
        anchors.horizontalCenter: parent.horizontalCenter
        text: getDefaultVoteLabelText()
    }
    function getVotedStatusColor() {
        var color = isUpOrDownButton() ? "green" : "red"
        return (voteOn ? color : "transparent")
    }
    function getDefaultVoteLabelText() {
        if (isUpOrDownButton()) {
            return qsTr("Vote up")
        }
        else {
            return qsTr("Vote down")
        }
    }
    function getVoteButtonImage() {
        return isUpOrDownButton() ? voteUpButtonImage : voteDownButtonImage
    }
    function isUpOrDownButton() {
        if(buttonType === question_vote_up || buttonType === answer_vote_up)
            return true
        return false
    }
    function isAnswerTypeButton() {
        if(buttonType === answer_vote_up || buttonType === answer_vote_down)
            return true
        return false
    }
    function setVoteStatus(status) {
        voteOn = status
    }
    function setOppositeVoteButtonStatus(status) {
        if (oppositeVoteButton !== null) {
            oppositeVoteButton.setVoteStatus(status)
        }
    }
    function getVoteStatus() {
        return voteOn
    }
    function getOppositeVoteButtonStatus() {
        if (oppositeVoteButton !== null) {
            return oppositeVoteButton.getVoteStatus()
        }
    }
    function setVotesToQuestionModel(votes) {
        questionsModel.set(index, {"votes": votes.toString()})
    }
    function vote(id) {
        var script =""
        if (buttonType === question_vote_up)
            script = "document.getElementById('question-img-upvote-" + id + "').click();"
        if (buttonType === question_vote_down)
            script = "document.getElementById('question-img-downvote-" + id + "').click();"
        if (buttonType === answer_vote_up)
            script = "document.getElementById('answer-img-upvote-" + id + "').click();"
        if (buttonType === answer_vote_down)
            script = "document.getElementById('answer-img-downvote-" + id + "').click();"
        webViewPage.evaluateJavaScriptOnWebPage(script, function(result) {
            if (getOppositeVoteButtonStatus())
                voteOn = false
            else
                voteOn = true
            setOppositeVoteButtonStatus(false)
            if (!isAnswerTypeButton())
                setVotesToQuestionModel(parseInt(initialVotes) + (isUpOrDownButton() ? 1 : -1))
            console.log("Voted " + id + ", result: " + voteOn)
            voted()
        })
    }
}


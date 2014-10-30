import QtQuick 2.0
import Sailfish.Silica 1.0

Image {
    id: voteButton
    property int question_vote_up: 1
    property int question_vote_down: 2
    property int answer_vote_up: 3
    property int answer_vote_down: 4
    property int buttonType: question_vote_up

    property bool voteOn: false
    property int initialVotes: 0
    property string votingTargetId
    property bool userLoggedIn: true
    property var userNotifObject: null
    property real scaling: 1.2
    property var webViewPage: pageStack.nextPage()
    property var oppositeVoteButton: null // to set status of e.g. down vote button if this is up button
    signal voted()

    property string voteButtonImage: "qrc:/qml/images/arrow-right.png"
    property string voteButtonUpVotedImage: "qrc:/qml/images/arrow-right-vote-up.png"
    property string voteButtonDownVotedImage: "qrc:/qml/images/arrow-right-vote-down.png"
    property string voteButtonPressedImage: "qrc:/qml/images/arrow-right-pressed.png"

    source: getVoteButtonImage()
    rotation: isUpOrDownButton() ? -90 : +90
    scale: scaling
    MouseArea {
        id: mousearea
        anchors.fill: parent
        onPressed: {
            if (userLoggedIn) {
                if (!voteOn)
                    voteButton.source = voteButtonPressedImage
                else {
                    if (userNotifObject !== null)
                        userNotifObject.showText(qsTr("Already voted up!"))
                }
            }
            else {
                if (userNotifObject !== null)
                    userNotifObject.showText(qsTr("Please log in to vote!"))
            }
        }
        onReleased: {
            if (!voteOn && userLoggedIn) {
                voteButton.refreshSource()
                console.log("Voting " + (isUpOrDownButton() ? "UP" : "DOWN"))
                vote(votingTargetId)
            }
        }
    }
    function refreshSource() {
        voteButton.source = getVoteButtonImage()
    }
    function getVoteButtonImage() {
        return isUpOrDownButton() ? (voteOn ? voteButtonUpVotedImage : voteButtonImage) :
                                    (voteOn ? voteButtonDownVotedImage : voteButtonImage)
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
        refreshSource()
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
        questionsModel.set(index, {"votes": votes})
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
            refreshSource()
            if (!isAnswerTypeButton())
                setVotesToQuestionModel(initialVotes + (isUpOrDownButton() ? 1 : -1))
            console.log("Voted " + id + ", result: " + voteOn)
            voted()
        })
    }
}


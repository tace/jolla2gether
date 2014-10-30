import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

ListItem  {
    id: answerCommentItem
    anchors.left: parent.left
    anchors.right: parent.right
    width: parent.width
    anchors.leftMargin: Theme.paddingLarge
    anchors.rightMargin: Theme.paddingMedium
    contentHeight: answersAndCommentsColumn.height
    height: contentHeight
    _showPress: false // Disable normal list item highlighting

    property int answerVotes: 0
    property bool upvotedThisAnswer: false
    property bool downvotedThisAnswer: false
    property bool answerAccepted: false
    property bool upvotedThisComment: false
    property int numberOfCommentUpVotes: 0
    property string relatedQuestionOrAnswerNumber: qid // Relevant for comments only
    property string answerUserName: "" // Relevant for answer wiki posts where answer updating user is set here

    Timer {
        id: waitingWebResultsTimer
        interval: 1500 + Math.floor((Math.random() * 100) + 20);
        onTriggered: {
            console.log("Timer triggered, interval was: " +interval)
            get_comment_data(getAnswerOrCommentNumber(), answerCommentItem)
        }
    }
    function startWebTimer() {
        waitingWebResultsTimer.start()
        console.log("Started web timer for item: " + getAnswerOrCommentNumber())
    }
    // Relevant for comments only
    function setRelatedAnswerNumber(id) {
        relatedQuestionOrAnswerNumber = id
        //console.log("Comment " + getAnswerOrCommentNumber() + " is related to " + (id === qid ? "question " : "answer ") + id)
    }
    function getRelatedAnswerNumber() {
        return relatedQuestionOrAnswerNumber
    }
    function getTextSize() {
        //return Theme.fontSizeTiny // Default
        //return Theme.fontSizeSmall
        //return Theme.fontSizeMedium
        //return Theme.fontSizeLarge
        //return Theme.fontSizeExtraLarge
        return appSettings.question_view_page_answers_and_comments_font_size_value
    }

    Column {
        id: answersAndCommentsColumn
        width: parent.width
        height: childrenRect.height
        Separator {
            width: parent.width
            horizontalAlignment: Qt.AlignCenter
            color: Theme.secondaryHighlightColor
            height: 1
        }
        Row {
            width: parent.width
            height: !isAnswer() ? titleLabel.height : childrenRect.height
            Column {
                id: titleAndUserImageColumn
                height: childrenRect.height
                width: parent.width
                Row {
                    width: parent.width
                    Label {
                        id: titleLabel
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                        text: getTitle() + getUserFormatted() + "  " + getTimeForTitle()
                    }
                    Item {
                        height: 1
                        width: isAnswer() ? 1 : parent.width -
                                            titleLabel.width -
                                            commentVotingButton.width -
                                            Theme.paddingMedium
                    }
                    Rectangle {
                        id: commentVotingButton
                        visible: ! isAnswer() // Comment
                        height: titleLabel.height
                        width: commentLikeRow.width + 10
                        border.width: 0
                        color: "transparent"
                        Row {
                            id: commentLikeRow
                            anchors.horizontalCenter: commentVotingButton.horizontalCenter
                            Item {
                                height: 1
                                width: Theme.paddingSmall
                            }
                            Image {
                                id: commentLikeImage
                                width: 32
                                height: 32
                                smooth: true
                                source: "image://theme/icon-s-like"
                            }
                            Item {
                                height: 1
                                width: Theme.paddingSmall
                            }
                            Label {
                                id: commentVoteAmountLabel
                                visible: numberOfCommentUpVotes > 0
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: upvotedThisComment ? true : false
                                color: upvotedThisComment ? "red" : Theme.secondaryHighlightColor
                                text: numberOfCommentUpVotes
                            }
                            Item {
                                height: 1
                                width: Theme.paddingSmall
                            }
                        }
                        MouseArea {
                            enabled: ! infoBanner.visible()
                            anchors.fill: parent
                            onClicked: {
                                if (amILoggedIn(qsTr("Please log in to upvote comments!")))
                                    voteUpComment(getAnswerOrCommentNumber())
                            }
                        }
                    }
                }
                Row {
                    visible: isAnswer()
                    Image {
                        id: answeredUserPic
                        visible: isAnswer()
                        width: 80
                        height: 80
                        smooth: true
                        source: ""
                    }
                    Item {
                        height: 1
                        width: Theme.paddingSmall
                    }
                    Column {
                        id: userStatsAndFlagColumn
                        visible: isAnswer()
                        Row {
                            Label {
                                id: userLabel
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.secondaryColor
                                text: "<b>" + getUser() + "</b>"
                            }
                            Item {
                                height: 1
                                width: Theme.paddingSmall
                            }
                            AnimatedImage {
                                id: answerFlagImage
                                anchors.verticalCenter: userLabel.verticalCenter
                                anchors.leftMargin: Theme.paddingMedium
                                width: 16
                                height: 11
                                smooth: true
                                source: ""
                            }
                        }
                        Label {
                            id: karmaLabel
                            font.pixelSize: Theme.fontSizeTiny
                            color: Theme.secondaryColor
                            text: ""
                        }
                        Label {
                            id: timeLabel
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.secondaryColor
                            text: getTimeString()
                        }
                    }
                }
            }
            Item {
                id: fillSpace
                height: 1
                width: parent.width - titleAndUserImageColumn.width - answerButtonsRow.width
            }
            Row {
                id: answerButtonsRow
                visible: isAnswer()
                Image {
                    id: acceptAnswerButton
                    visible: isMyOwnQuestion() || answerAccepted
                    anchors.verticalCenter: votingButtonsColumn.verticalCenter
                    width: 64
                    height: 64
                    source: answerAccepted ? "qrc:/qml/images/answer-accepted.png" : "qrc:/qml/images/answer-not-accepted.png"
                    MouseArea {
                        enabled: ! infoBanner.visible()
                        anchors.fill: parent
                        onClicked: {
                            acceptAnswer(getAnswerOrCommentNumber())
                        }
                    }
                }
                Item {
                    height: 1
                    width: Theme.paddingMedium
                }
                Column {
                    id: votingButtonsColumn
                    height: childrenRect.height
                    anchors.rightMargin: Theme.paddingMedium
                    VotingButton {
                        id: voteUpButton
                        buttonType: voteUpButton.answer_vote_up
                        userNotifObject: infoBanner
                        userLoggedIn: questionsModel.isUserLoggedIn()
                        oppositeVoteButton: voteDownButton
                        votingTargetId: getAnswerOrCommentNumber()
                        onVoted: {
                            answerVotes += 1
                        }
                    }
                    StatsRectangle {
                        id: votesRectangle
                        anchors.horizontalCenter: voteUpButton.horizontalCenter
                        topLabelText: answerVotes
                        topLabelFontColor: "lightgreen"
                        bottomLabelText: qsTr("votes")
                        bottomLabelFontColor: Theme.secondaryColor
                    }
                    VotingButton {
                        id: voteDownButton
                        buttonType: voteDownButton.answer_vote_down
                        userNotifObject: infoBanner
                        userLoggedIn: questionsModel.isUserLoggedIn()
                        oppositeVoteButton: voteUpButton
                        votingTargetId: getAnswerOrCommentNumber()
                        onVoted: {
                            answerVotes -= 1
                        }
                    }
                }
            }
            //            Image {
            //                id: textSelect
            //                visible: textSelectionEnabled
            //                anchors.right: parent.right
            //                anchors.rightMargin: Theme.paddingMedium
            //                source: "image://theme/icon-m-clipboard"
            //                MouseArea {
            //                    anchors.fill: parent
            //                    onClicked: {
            //                        answerCommentText.toggleTextSelectMode()
            //                    }
            //                }
            //            }
        }

        ShowRichTextWithLinkActions {
            id: answerCommentText
            fontSize: getTextSize()
            text: questionsModel.wiki2Html(description)
            textBanner: infoBanner
        }

        Item {
            id: filler
            width: 1
            anchors.left: parent.left
            height: Theme.paddingLarge
        }
    }
    function getPlainText() {
        return answerCommentText.getPlainText()
    }
    function selectAndMovetoText(start, end) {
        return answerCommentText.selectAndMovetoText(start, end)
    }
    function resetSearchTextSelection() {
        answerCommentText.resetTextSelection()
    }
    function isAnswer() {
        if (category == rssFeedModel.answerFilter)
            return true
        return false
    }
    function isMyOwnQuestion() {
        if (questionsModel.ownUserIdValue === userId)
            return true
        return false
    }
    function getTitle() {
        if (isAnswer())
            return "<font color=\"orange\">Answer</font> by"
        return "<font size=\"1\">Comment by</font>"
    }
    function getOrigUserFromTitle() {
        return title.split(" ")[2]
    }
    // E.g. "Comment by tace ..."
    function getUser() {
        return updatedAnswerUser() ? answerUserName : getOrigUserFromTitle()
    }
    function getUserFormatted() {
        if (isAnswer())
            return updatedAnswerUser() ?  " " + getOrigUserFromTitle() + " Updated by" : ""
        return " <b>" + getUser() + "</b>"
    }
    function getTimeString() {
        return "<font size=\"1\">" + questionsModel.rssPubdate2ElapsedTimeString(pubDate) + "</font>"
    }
    function getTimeForTitle() {
        if (isAnswer())
            return ""
        return getTimeString()
    }
    //
    // Returns answer or comment number from <link> url address.
    // E.g. https://together.jolla.com/question/54447/telnet-communication-difficulties/?answer=54605#post-id-54605
    // ==> 54605 returned
    function getAnswerOrCommentNumber() {
        var lastPartSplitString = "#comment-"
        var answerOrCommentString = rssFeedModel.commentFilter
        if (isAnswer()) {
            lastPartSplitString = "#post-id-"
            answerOrCommentString = rssFeedModel.answerFilter
        }
        return link.split("/?" +answerOrCommentString+ "=")[1].split(lastPartSplitString)[0]
    }
    function setAnswerVotingButtonsStatus(up, down) {
        voteUpButton.setVoteStatus(up)
        voteDownButton.setVoteStatus(down)
    }
    function setGravatarImagesUrls(gravatarUrl, flagUrl) {
        answeredUserPic.source = "http:" + usersModel.changeImageLinkSize(gravatarUrl, 80)
        if (flagUrl !== "")
            answerFlagImage.source = siteBaseUrl + flagUrl
    }
    function setAnswerUserName(user) {
        answerUserName = user
    }
    // for wiki posts answers can be updated by anyone and then answered user changes
    function updatedAnswerUser() {
        if ((answerUserName !== "") && (answerUserName !== getOrigUserFromTitle()))
            return true
        return false
    }
    function setKarma(karma) {
        karmaLabel.text = "Karma: " + karma
    }
    function setAcceptedAnswerFlag(flag) {
        if (flag)
            answerAccepted = true
        else
            answerAccepted = false
    }
    function acceptAnswer(answer_id) {
        if (!isMyOwnQuestion()) {
            infoBanner.showText(qsTr("Sorry, only moderators or original author of the question can accept or unaccept the best answer"))
            console.log("Question author " + userId + " is different than your own id: " + questionsModel.ownUserIdValue)
            return
        }
        var script = "document.getElementById('answer-img-accept-" + answer_id + "').click();"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            if (answerAccepted)
                answerAccepted = false
            else
                answerAccepted = true
            var infoText = qsTr("Answer accepted")
            if (!answerAccepted)
                infoText = qsTr("Un-accepted answer")
            infoBanner.showText(infoText)
        })
    }
    function voteUpComment(comment_id) {
        if (upvotedThisComment) {
            infoBanner.showText(qsTr("Already upvoted this comment!"))
            console.log("Already upvoted this comment")
            return
        }
        var script = "var commentElem = document.getElementById('comment-" + comment_id + "'); \
                      var commentSubs = commentElem.getElementsByTagName('div'); \
                      for (var i = 0; i < commentSubs.length; i++) { \
                          if (commentSubs[i].getAttribute('class') === 'upvote') { \
                              commentSubs[i].click(); \
                              break; \
                          } \
                      }"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            numberOfCommentUpVotes += 1
            upvotedThisComment = true
            console.log("Upvoted comment "+ comment_id + ", result: "+result)
        })
    }
    function setCommentVotesData(upvoted, nbrOfVotes) {
        upvotedThisComment = upvoted
        numberOfCommentUpVotes = nbrOfVotes
    }
}

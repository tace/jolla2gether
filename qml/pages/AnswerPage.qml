import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0
import "../components"

Page {
    id: answerPage
    objectName: "AnswerPage"
    allowedOrientations: Orientation.All

    property int questionIndex: 0
    property string answerId
    property string answerUser
    property string text: ""
    property string pubDate
    property XmlListModel rssFeedModel

    property bool answerAccepted: false
    property int answerVotes
    property bool answerDataLoaded: false

    InfoBanner {
        id: infoBanner
    }

    function answerDataCallback(upVote,
                                downVote,
                                answerVotesValue,
                                gravatarUrl,
                                flagUrl,
                                answerUsername,
                                karma,
                                answerAcceptedBool) {
        answeredUserPic.source = "http:" + usersModel.changeImageLinkSize(gravatarUrl, 100)
        if (flagUrl !== "")
            answerFlagImage.source = siteBaseUrl + flagUrl
        userLabel.text = "<b>" + answerUsername + "</b>"
        karmaLabel.text = "Karma: " + karma
        answerAccepted = answerAcceptedBool
        answerVotes = answerVotesValue
        voteUpButton.setVoteStatus(upVote)
        voteDownButton.setVoteStatus(downVote)
        answerDataLoaded = true
    }
    function getAnswerId() {
        return answerId
    }

    function getPageTextFontSize() {
        return appSettings.question_view_page_font_size_value
    }


    Component.onCompleted: {
        console.log("answerId: " + answerId)
        rssFeedModel.loadInitialAnswersOrComments()
    }


    onStatusChanged: {
        if (status === PageStatus.Active) {
            console.log("answerpage active")
            attachWebview()
            forwardNavigation = false
        }
        else if (status === PageStatus.Inactive) {
            console.log("answerpage Inactive")
            rssFeedModel.unloadAnswer()
            unattachWebview()
        }
    }


    SilicaFlickable {
        id: contentFlickable
        anchors.fill: parent
        contentHeight: heighBeforeTextContent() +
                       answerContentColumn.height
        focus: true
        Keys.onEscapePressed: {
            pageStack.navigateBack()
        }
        Keys.onUpPressed: {
            scrollUp()
        }
        Keys.onDownPressed: {
            scrollDown()
        }
        CtrlPlusKeyPressed {
            id: ctrlHandler
            key: Qt.Key_F
            onCtrlKeyPressed: {
                searchBanner.show()
            }
        }
        Keys.onPressed: {
            ctrlHandler.Keys.pressed(event)
        }
        Keys.onReleased: {
            ctrlHandler.Keys.released(event)
        }

        function scrollDown () {
            contentY = Math.min (contentY + (height / 4), contentHeight - height);
        }
        function scrollUp () {
            contentY = Math.max (contentY - (height / 4), 0);
        }
        PageHeader {
            id: pageHeader
            title: qsTr("Answer")
        }
        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                text: qsTr("Search...")
                onClicked: {
                    searchBanner.show()
                }
            }
        }

        Column {
            id: answerContentColumn
            anchors.top: pageHeader.bottom
            width: parent.width
            height: childrenRect.height

            Row {
                width: parent.width
                Item {
                    height: 1
                    width: Theme.paddingMedium
                }
                Image {
                    id: answeredUserPic
                    width: 100
                    height: 100
                    smooth: true
                    source: ""
                }
                Item {
                    height: 1
                    width: Theme.paddingMedium
                }
                Column {
                    id: userStatsAndFlagColumn
                    width: parent.width
                    Row {
                        Label {
                            id: userLabel
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.secondaryColor
                            text: "<b>" + answerUser + "</b>"
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
                        text: questionsModel.rssPubdate2ElapsedTimeString(pubDate)
                    }
                }

                Item {
                    id: fillSpace
                    height: 1
                    width: parent.width -
                           userStatsAndFlagColumn.width -
                           answeredUserPic.width -
                           answerButtonsRow.width - Theme.paddingMedium * 2
                }
                Row {
                    id: answerButtonsRow
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
                                acceptAnswer(answerId)
                            }
                        }
                    }
                    Item {
                        height: 1
                        width: Theme.paddingMedium * 3
                    }
                    Column {
                        id: votingButtonsColumn
                        visible: answerDataLoaded
                        height: childrenRect.height
                        anchors.rightMargin: Theme.paddingMedium
                        VotingButton {
                            id: voteUpButton
                            buttonType: voteUpButton.answer_vote_up
                            userNotifObject: infoBanner
                            userLoggedIn: questionsModel.isUserLoggedIn()
                            oppositeVoteButton: voteDownButton
                            votingTargetId: answerId
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
                            votingTargetId: answerId
                            onVoted: {
                                answerVotes -= 1
                            }
                        }
                    }
                }
            }
            Item {
                width: 1
                height: Theme.paddingLarge
            }

            ShowRichTextWithLinkActions {
                id: answerText
                fontSize: getPageTextFontSize()
                text: questionsModel.wiki2Html(answerPage.text)
                textBanner: infoBanner
                parentFlickable: contentFlickable
            }

            Item {
                width: 1
                height: Theme.paddingLarge * 3
            }

            RssFeedRepeater {
                id: commentsFeed
                buttonVisible: rssFeedModel.pagingModelAnswerComments.ready && rssFeedModel.getTotalAnswerCommentsCount() > 0
                modelReady: rssFeedModel.pagingModelAnswerComments.ready
                buttonActivated: rssFeedModel.answerCommentsListOpen && rssFeedModel.getAnswerCommentsCount() > 0
                buttonLabelText: getButtonText()
                repeaterModel: rssFeedModel.answerCommentsRssModel
                repeaterDelegate: CommentsDelegate { loadCommentData: answerDataLoaded
                                                     relatedQuestionOrAnswerNumber: answerId}
                onButtonPressed: {
                    rssFeedModel.openAnswersOrCommentsRssFeedList(false)
                }
                onSortAscPressed: {
                    rssFeedModel.triggerFeedWorker(rssFeedModel.commentFilter, rssFeedModel.sORT_ASC)
                }
                onSortDescPressed: {
                    rssFeedModel.triggerFeedWorker(rssFeedModel.commentFilter, rssFeedModel.sORT_DESC)
                }
                function getButtonText() {
                    if (!rssFeedModel.pagingModelAnswerComments.ready) {
                        return qsTr("Loading Comments...")
                    }
                    if (rssFeedModel.getTotalAnswerCommentsCount() > 0) {
                        var commentsText = rssFeedModel.getTotalAnswerCommentsCount() === 1 ? qsTr(" Comment") : qsTr(" Comments")
                        return (!rssFeedModel.answerCommentsListOpen ? rssFeedModel.getTotalAnswerCommentsCount() : "") + commentsText + (rssFeedModel.answerCommentsListOpen ? " (" + rssFeedModel.getAnswerCommentsCount() + "/" + rssFeedModel.getTotalAnswerCommentsCount() + ")" : "")
                    }
                    else {
                        return qsTr("No Comments")
                    }
                }
            }
            Item {
                width: 1
                height: Theme.paddingLarge
            }
        }
        ScrollDecorator { }
        onAtYEndChanged: {
            if (atYEnd && contentY >= parent.height && rssFeedModel.answerCommentsListOpen) {
                if (contentY > 0 && parent.height > 0) {
                    console.log("At end of page, load next answers/comments")
                    if (!urlLoading)  // Important to prevent simultaneous loading with workerscript
                        rssFeedModel.loadMoreAnswersOrComments()
                }
            }
        }

        function ensureVisible(r)
        {
            if (searchBanner.opened) {
                contentY += searchBanner.height
            }

            if (contentX >= r.x)
                contentX = r.x;
            else if (contentX+width <= r.x+r.width)
                contentX = r.x+r.width-width;
            if (contentY >= r.y)
                contentY = r.y;
            else if (contentY+height <= r.y+r.height)
                contentY = r.y+r.height-height;
        }
        function heighBeforeTextContent() {
            return pageHeader.height +
                    voteUpButton.height +
                    voteDownButton.height
        }

    }
    SearchBanner {
        id: searchBanner
        foreground: contentFlickable
        mainFlickable: contentFlickable
        pageMainTextElement: answerText
        pageDynamicTextModelElement: commentsFeed
    }
    function acceptAnswer(answer_id) {
        if (!isMyOwnQuestion()) {
            infoBanner.showText(qsTr("Sorry, only moderators or original author of the question can accept or unaccept the best answer"))
            console.log("Question author " + questionsModel.get(questionIndex).author_id + " is different than your own id: " + questionsModel.ownUserIdValue)
            return
        }
        var script = "document.getElementById('answer-img-accept-" + answer_id + "').click();"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            answerAccepted = !answerAccepted
            var infoText = qsTr("Answer accepted")
            if (!answerAccepted)
                infoText = qsTr("Un-accepted answer")
            infoBanner.showText(infoText)
        })
    }
    function isMyOwnQuestion() {
        if (questionsModel.ownUserIdValue === questionsModel.get(questionIndex).author_id)
            return true
        return false
    }

}

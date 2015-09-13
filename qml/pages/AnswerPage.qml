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
    property int userPicSize: pageSmallestSideLenght / 5
    property int flagPicHeight: userLabel.height
    property int flagPicWidth: flagPicHeight * 1.455

    readonly property int pageSmallestSideLenght: getPageOriginalWidthOrHeighBasedOnOrientation()

    function getPageOriginalWidthOrHeighBasedOnOrientation() {
        if (phoneOrientation === Orientation.Landscape ||
                phoneOrientation === Orientation.LandscapeInverted) {
            return height
        }
        else {
            return width
        }
    }

    InfoBanner {
        id: infoBanner
    }

    Component.onCompleted: {
        console.log("answerId: " + answerId)
        rssFeedModel.loadInitialAnswersOrComments()
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            console.log("answerpage active")
            attachWebview()
        }
        else if (status === PageStatus.Inactive) {
            console.log("answerpage Inactive")
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
                    width: userPicSize
                    height: userPicSize
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
                            width: flagPicWidth
                            height: flagPicHeight
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
                           votesRow.width - Theme.paddingLarge * 3
                }
                Row {
                    id: votesRow
                    Column {
                        BusyIndicator {
                            id: busyIndicator
                            size: BusyIndicatorSize.Small
                            running: !answerDataLoaded
                        }
                        Label {
                            id: answerPageLoadinLabel
                            visible: !answerDataLoaded
                            font.pixelSize: Theme.fontSizeTiny
                            color: Theme.secondaryColor
                            text: ""
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
                        StatsRectangle {
                            id: votesRectangle
                            topLabelText: answerVotes.toString()
                            topLabelFontColor: "lightgreen"
                            topLabelFontSize: Theme.fontSizeMedium
                            bottomLabelText: qsTr("votes")
                            bottomLabelFontColor: Theme.secondaryColor
                            bottomLabelFontSize: Theme.fontSizeMedium
                        }
                    }
                }
            }
            Item {
                width: 1
                height: Theme.paddingLarge
            }
            ButtonPanel {
                id: actionButtons
                visible: answerDataLoaded
                //width: parent.width - 2 * Theme.paddingLarge

                // Search button
                customButton1.icon.source: "image://theme/icon-m-search"
                customButton1.onClicked: {
                    searchBanner.show()
                }
                customButtom1LabelText: qsTr("Search")

                // AcceptAnswer button
                customButton2.icon.source: "image://theme/icon-m-dot?" + (answerAccepted
                                                                          ? "green"
                                                                          : Theme.primaryColor)
                customButton2.enabled: ! infoBanner.visible()
                customButton2.onClicked: {
                    acceptAnswer(answerId)
                }
                customButtom2LabelText: answerAccepted ? qsTr("Answer accepted") : qsTr("Accept answer")

                voteButtonsTargetId: answerId
                voteUpButton.buttonType: voteUpButton.answer_vote_up
                voteDownButton.buttonType: voteDownButton.answer_vote_down
                voteUpButton.onVoted: {
                    answerVotes += 1
                }
                voteDownButton.onVoted: {
                    answerVotes -= 1
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
                height: Theme.paddingLarge * 2
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
                    actionButtons.height
        }

    }
    SearchBanner {
        id: searchBanner
        foreground: contentFlickable
        mainFlickable: contentFlickable
        pageMainTextElement: answerText
        pageDynamicTextModelElement: commentsFeed.feedRepeater
    }
    function getPageTextFontSize() {
        return appSettings.question_view_page_font_size_value
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
    function answerDataCallback(upVote,
                                downVote,
                                answerVotesValue,
                                gravatarUrl,
                                flagUrl,
                                answerUsername,
                                karma,
                                answerAcceptedBool) {
        answeredUserPic.source = "http:" + usersModel.changeImageLinkSize(gravatarUrl, userPicSize)
        if (flagUrl !== "")
            answerFlagImage.source = siteBaseUrl + flagUrl
        userLabel.text = "<b>" + answerUsername + "</b>"
        karmaLabel.text = "Karma: " + karma
        answerAccepted = answerAcceptedBool
        answerVotes = parseInt(answerVotesValue)
        actionButtons.setVoteStatuses(upVote, downVote)
        answerDataLoaded = true
    }
    function getAnswerId() {
        return answerId
    }

    function getAnswerDataFromWebViewCallback(runInWebviewCallback) {
        var scriptToRun = "(function() { \
                  var upvoteElem = document.getElementById('answer-img-upvote-" + answerId + "'); \
                  var upvoteOn = upvoteElem.getAttribute('class').split('answer-img-upvote post-vote upvote')[1]; \
                  var downvoteElem = document.getElementById('answer-img-downvote-" + answerId + "'); \
                  var downvoteOn = downvoteElem.getAttribute('class').split('answer-img-downvote post-vote downvote')[1]; \
                  var voteNumberElem = document.getElementById('answer-vote-number-" + answerId + "'); \
                  var votes = voteNumberElem.childNodes[0].nodeValue; \
                  var answerPost = document.getElementById('post-id-" + answerId + "'); \
                  var images = answerPost.getElementsByTagName('img'); \
                  var gravatarUrl = ''; \
                  var userName = ''; \
                  var flagUrl = ''; \
                  for (var i = 0; i < images.length; i++) { \
                      if (images[i].getAttribute('class') === 'gravatar' && gravatarUrl === '') { \
                          gravatarUrl = images[i].getAttribute('src'); \
                          userName = images[i].getAttribute('title'); \
                      } \
                      if (images[i].getAttribute('class') === 'flag' && flagUrl === '') { \
                          flagUrl = images[i].getAttribute('src'); \
                      } \
                  } \
                  var karma = 0; \
                  var karmaElem = answerPost.getElementsByTagName('span')[0]; \
                  if (karmaElem.getAttribute('class') === 'reputation-score') { \
                      karma = karmaElem.childNodes[0].nodeValue; \
                  } \
                  var answerAccepted = false; \
                  var answerAcceptedElem = document.getElementById('answer-img-accept-" + answerId + "'); \
                  if (answerAcceptedElem.getAttribute('title') === 'this answer has been selected as correct') { \
                      answerAccepted = true; \
                  } \
                  return upvoteOn + ',' + downvoteOn + ',' + votes + ',' + gravatarUrl + ',' + flagUrl + ',' + userName + ',' + karma + ',' + answerAccepted \
                  })()"
        var handleResult = function(result) {
            if (result === undefined) {
                loadNextAnswerPage()
                return
            }

            console.log("Answer: " + answerId + ", result: " + result)
            var answerData = result.split(',')
            var upVote = false
            var downVote = false
            if (answerData[0].trim() !== '')
                upVote = true
            if (answerData[1].trim() !== '')
                downVote = true
            var answerVotes = "0"
            if (answerData[2].trim() !== '')
                answerVotes = answerData[2].trim()
            var gravatarUrl = answerData[3].trim()
            var flagUrl = answerData[4].trim()
            var answerUsername = answerData[5].trim()
            var karma = answerData[6].trim()
            answerDataCallback(upVote,
                               downVote,
                               answerVotes,
                               gravatarUrl,
                               flagUrl,
                               answerUsername,
                               karma,
                               answerData[7].trim() === "true")
        }

        if (runInWebviewCallback) {
            console.log("return as callback to webview")
            return function(webview) {
                webview.evaluateJavaScriptOnWebPage(scriptToRun, handleResult)
            }
        }
        else {
            console.log("call implicitly to find answer " + answerId)
            pageStack.nextPage().evaluateJavaScriptOnWebPage(scriptToRun, handleResult)
        }
    }
    function loadNextAnswerPage() {
        var script = "(function() { \
                      var contentLeft = document.getElementById('ContentLeft'); \
                      var divs = contentLeft.getElementsByTagName('div'); \
                      var currentPage = ''; \
                      var totalPages = ''; \
                      for (var i = 0; i < divs.length; i++) { \
                          if (divs[i].getAttribute('class') === 'paginator') { \
                              var spans = divs[i].getElementsByTagName('span'); \
                              for (var j = 0; j < spans.length; j++) { \
                                  if (spans[j].getAttribute('class') === 'curr') { \
                                      currentPage = spans[j].childNodes[0].nodeValue; \
                                  } \
                                  if (spans[j].getAttribute('class') === 'page') { \
                                      totalPages = spans[j].getElementsByTagName('a')[0].childNodes[0].nodeValue; \
                                  } \
                                  if (spans[j].getAttribute('class') === 'next') { \
                                      spans[j].getElementsByTagName('a')[0].click(); \
                                  } \
                              } \
                              break; \
                          } \
                      } \
                      return currentPage + ',' + totalPages; \
                      })()"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            var data = result.split(',')
            var currentPageNum = parseInt(data[0].trim()) + 1
            var totalPages = data[1].trim()
            answerPageLoadinLabel.text = qsTr("Searching answer ") + currentPageNum + '/' + totalPages
        })
    }
}

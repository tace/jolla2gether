import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../models"

Page {
    id: page
    objectName: "QuestionViewPage"
    allowedOrientations: Orientation.All

    property int index: 0
    property string qid: questionsModel.get(index).id
    property string title: questionsModel.get(index).title
    property string text: questionsModel.get(index).text
    property string url: questionsModel.get(index).url
    property string asked: questionsModel.get(index).created_date
    property string updated: questionsModel.get(index).updated_date
    property string userId: questionsModel.get(index).author_id
    property string userName: questionsModel.get(index).author
    property string userPageUrl: questionsModel.get(index).author_page_url
    property int votes: questionsModel.get(index).votes
    property string answer_count: questionsModel.get(index).answer_count
    property string view_count: questionsModel.get(index).view_count
    property string tags: questionsModel.get(index).tags
    property var tagsArray: null
    property string userKarma: ""
    property string userAvatarUrl: ""
    property bool openExternalLinkOnWebview: false
    property string externalUrl: ""
    property bool answersAndCommentsOpen: false
    property bool answersAndCommentsClicked: false
    property string rssFeedUrl: siteBaseUrl + "/feeds/question/" + qid + "/"
    property bool upVoteOn: false
    property bool downVoteOn: false
    property bool voteStatusLoaded: false
    property bool textSelectionEnabled: false
    property bool followedStatusLoaded: false
    property bool followed: false
    property var startTime
    property var endTime

    InfoBanner {
        id: infoBanner
    }
    ListModel {
        id: finalRssModel
        property bool ready: false
    }
    ListModel {
        id: sortModel
    }
    ListModel {
        id: pagingListModel
        property int pageSize: 20 // 20 answers or comments at a time
        property int currentIndex: 0 // Keep track of point in total rss feed index
        property int pageStopIndex: 0
    }
    RssFeedModel {
        id: rssFeedModel
        pagingModel: pagingListModel
        sortingModel: sortModel
    }

    function goToItem(idx) {
        var props = {
            "index": idx
        };
        pageStack.replace("QuestionViewPage.qml", props);
    }

    onFollowedStatusLoadedChanged: {
        if (followedStatusLoaded) {
            if (answersAndCommentsClicked) {
                // If user has already clicked answersAndComments open, do it actually just now after
                // followedStatus loading is finished to make sure webview is ready for it.
                rssFeedModel.source = rssFeedUrl
            }
        }
    }

    function loadAnswersAndComments() {
        startTime = Date.now()
        if (!answersAndCommentsClicked) {
            urlLoading = true
            answersAndCommentsClicked = true
            if (followedStatusLoaded) {
                // Start loading RssFeed only after webview is surely loaded,
                // so link it to the followed status which is the last callback run on webview start
                rssFeedModel.source = rssFeedUrl
            }
        }
        if (answersAndCommentsOpen) {
            answersAndCommentsOpen = false
            rssFeedModel.initRssModel()
        }
        else {
            answersAndCommentsOpen = true
            if (finalRssModel.ready) {
                // Load only if model ready, otherwice it's ongoing
                rssFeedModel.fillRssModel(finalRssModel)
            }
        }
    }


    // Set some properties
    // after answer got from asyncronous (get_user) http request.
    function setUserData(user_data) {
        userKarma = user_data.reputation
        userAvatarUrl = "http:" + usersModel.changeImageLinkSize(user_data.avatar, 100) //match this size to userPic size
        //console.log("avatar: "+userAvatarUrl)
    }
    function getLabelMaxWidth() {
        return (askedLabel.paintedWidth + askedValue.paintedWidth) >
                (updatedLabel.paintedWidth + updatedValue.paintedWidth) ?
                    (askedLabel.width + askedValue.width) : (updatedLabel.width + updatedValue.width)
    }
    function getTagsArray() {
        return tags.split(",")
    }

    function getVotingResultsCallback() {
        return function votingResultsCallback(up, down) {
            voteDownButton.setVoteStatus(down)
            voteUpButton.setVoteStatus(up)
            voteStatusLoaded = true
        }
    }
    function followedStatusCallback(flag) {
        followed = flag
        followedStatusLoaded = true
    }
    function followQuestion() {
        var script = "var contentRight = document.getElementById('ContentRight'); \
                      var followButton = contentRight.getElementsByTagName('a')[0]; \
                      if (followButton.getAttribute('class') === 'button followed'); \
                          followButton.click();"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            if (followed)
                followed = false
            else
                followed = true
            console.log("Followed question: " + followed)
            var infoText = qsTr("Followed question")
            if (!followed)
                infoText = qsTr("Un-followed question")
            infoBanner.showText(infoText)
        })
    }
    function get_answer_data(answer_id, item) {
        var script = "(function() { \
                      var upvoteElem = document.getElementById('answer-img-upvote-" + answer_id + "'); \
                      var upvoteOn = upvoteElem.getAttribute('class').split('answer-img-upvote post-vote upvote')[1]; \
                      var downvoteElem = document.getElementById('answer-img-downvote-" + answer_id + "'); \
                      var downvoteOn = downvoteElem.getAttribute('class').split('answer-img-downvote post-vote downvote')[1]; \
                      var voteNumberElem = document.getElementById('answer-vote-number-" + answer_id + "'); \
                      var votes = voteNumberElem.childNodes[0].nodeValue; \
                      var answerPost = document.getElementById('post-id-" + answer_id + "'); \
                      var images = answerPost.getElementsByTagName('img'); \
                      var gravatarUrl = ''; \
                      var flagUrl = ''; \
                      for (var i = 0; i < images.length; i++) { \
                          if (images[i].getAttribute('class') === 'gravatar' && gravatarUrl === '') { \
                              gravatarUrl = images[i].getAttribute('src'); \
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
                      var answerAcceptedElem = document.getElementById('answer-img-accept-" + answer_id + "'); \
                      if (answerAcceptedElem.getAttribute('title') === 'this answer has been selected as correct') { \
                          answerAccepted = true; \
                      } \
                      return upvoteOn + ',' + downvoteOn + ',' + votes + ',' + gravatarUrl + ',' + flagUrl + ',' + karma + ',' + answerAccepted \
                      })()"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            console.log("Answer: " + answer_id + ", result: " + result)
            var answerData = result.split(',')
            var upVote = false
            var downVote = false
            if (answerData[0].trim() !== '')
                upVote = true
            if (answerData[1].trim() !== '')
                downVote = true
            if (answerData[2].trim() !== '')
                item.answerVotes = answerData[2].trim()
            item.setAnswerVotingButtonsStatus(upVote, downVote)
            item.setGravatarImagesUrls(answerData[3].trim(), answerData[4].trim())
            item.setKarma(answerData[5].trim())
            item.setAcceptedAnswerFlag(answerData[6].trim() === "true")
        })
    }
    function get_comment_data(comment_id, item, failCallback) {
        var script = "(function() { \
                      var commentElem = document.getElementById('comment-" + comment_id + "'); \
                      var commentSubs = commentElem.getElementsByTagName('div'); \
                      var numberOfVotes = 0; \
                      var iHaveUpvoted = false; \
                      for (var i = 0; i < commentSubs.length; i++) { \
                          if (commentSubs[i].getAttribute('class') === 'upvote upvoted') { \
                              iHaveUpvoted = true; \
                              numberOfVotes = commentSubs[i].childNodes[0].nodeValue; \
                          } \
                          if (commentSubs[i].getAttribute('class') === 'upvote') { \
                              numberOfVotes = commentSubs[i].childNodes[0].nodeValue; \
                          } \
                      } \
                      if (numberOfVotes === '') { \
                          numberOfVotes = 0; \
                      } \
                      return iHaveUpvoted + ',' + numberOfVotes; \
                      })()"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            if (result === undefined) {
                console.log("Failed to get comment data..." + comment_id)
                if (failCallback !== undefined) {
                    failCallback(item)
                    return
                }
            }
            console.log("Comment: " + comment_id + ", result: " + result)
            var commentData = result.split(',')
            item.setCommentVotesData(commentData[0].trim() === "true",
                                     commentData[1].trim())
        })
    }
    function pressSeeMoreCommentsButton(item) {
        var answer_id = item.getRelatedAnswerNumber()
        var script = "(function() { \
                      var addMoreButton = document.getElementById('add-comment-to-post-" + answer_id + "'); \
                      if (addMoreButton.childNodes[0].nodeValue === 'see more comments') { \
                          addMoreButton.click(); \
                      } \
                      })()"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            console.log("add-comment-to-post- button pressed, update comment data again")
            item.startWebTimer()
        })
    }

    function getPageTextFontSize() {
        //return Theme.fontSizeTiny
        //return Theme.fontSizeSmall // Default
        //return Theme.fontSizeMedium
        //return Theme.fontSizeLarge
        //return Theme.fontSizeExtraLarge
        return appSettings.question_view_page_font_size_value
    }
    function hasTags() {
        return tagsArray.length > 0 && tagsArray[0] !== ""
    }
    function amILoggedIn(error_text) {
        if (!questionsModel.isUserLoggedIn()) {
            infoBanner.showText(error_text)
            return false
        }
        return true
    }

    Connections {
        id: connections
        target: viewPageUpdater
        onChangeViewPage: {
            goToItem(pageIndex)
        }
    }

    Component.onCompleted: {
        usersModel.get_user(userId, setUserData)
        tagsArray = getTagsArray()
    }

    onStatusChanged: {
        if (status === PageStatus.Active && (url !== "" || externalUrl !== ""))
        {
            siteURL = page.url
            attachWebview()

            if (openExternalLinkOnWebview) {
                openExternalLinkOnWebview = false
                siteURL = externalUrl
                externalUrl = ""
                console.log("Opening external url: " + siteURL)
                pageStack.navigateForward()
            }
        }
    }

    SilicaFlickable {
        id: contentFlickable
        anchors.fill: parent
        contentHeight: heighBeforeTextContent() +
                       questionTextContentColumn.height

        PageHeader {
            id: pageHeader
            Label {
                id: userNameLabel
                anchors.top: pageHeader.top
                anchors.right: userPic.left
                anchors.topMargin: Theme.paddingSmall
                anchors.rightMargin: Theme.paddingSmall
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                text: "<b>" + userName + "</b>"
            }
            Label {
                id: userKarmaLabel
                anchors.top: userNameLabel.bottom
                anchors.right: userPic.left
                anchors.rightMargin: Theme.paddingSmall
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Karma: ") + userKarma
            }
            Image {
                id: userPic
                anchors.top: pageHeader.top
                anchors.right: pageHeader.right
                anchors.rightMargin: Theme.paddingSmall
                anchors.topMargin: Theme.paddingSmall
                width: 100
                height: 100
                smooth: true
                source: userAvatarUrl
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        siteURL = userPageUrl
                        pageStack.navigateForward()
                    }
                }
            }
        }
        PullDownMenu {
            id: pullDownMenu
            //
            // Disabled text selection feature as copy to system clipboard seems not to work constantly
            //
            //enabled: false
            //visible: false
            //            MenuItem {
            //                text: qsTr("Show text selection buttons")
            //                visible: !textSelectionEnabled
            //                onClicked: {
            //                    textSelectionEnabled = true
            //                }
            //            }
            //            MenuItem {
            //                text: qsTr("Hide text selection buttons")
            //                visible: textSelectionEnabled
            //                onClicked: {
            //                    textSelectionEnabled = false
            //                }
            //            }

            MenuItem {
                text: qsTr("Search...")
                onClicked: {
                    searchBanner.show()
                }
            }
        }
        Item {
            id: questionTitleItem
            anchors.top: pageHeader.bottom
            anchors.left: parent.left
            anchors.right: voteUpButton.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            height: childrenRect.height
            width: parent.width

            Label {
                id: pageTitle
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                horizontalAlignment: Text.AlignLeft
                width: parent.width
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                text: page.title

                MouseArea {
                    enabled: page.url !== ""
                    anchors.fill: parent
                    onClicked: {
                        siteURL = page.url
                        pageStack.navigateForward()
                    }
                }
            }
        }
        Item {
            id: titlePadding
            width: 1
            anchors.left: parent.left
            anchors.top: questionTitleItem.bottom
            height: Theme.paddingMedium
        }

        Rectangle {
            id: askedAdUpdatedTimesRec
            anchors.top: titlePadding.bottom
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            color: "transparent"
            width: getLabelMaxWidth()
            height: askedLabel.height + updatedLabel.height

            Label {
                id: askedLabel
                anchors.left: parent.left
                horizontalAlignment: Text.AlignLeft
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Asked") + ":"
            }
            Label {
                id: askedValue
                anchors.top: askedLabel.top
                anchors.left: updatedLabel.right
                horizontalAlignment: Text.AlignRight
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: asked
            }
            Label {
                id: updatedLabel
                anchors.top: askedLabel.bottom
                anchors.left: parent.left
                horizontalAlignment: Text.AlignLeft
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Updated") + ": "
            }
            Label {
                id: updatedValue
                anchors.top: updatedLabel.top
                anchors.left: updatedLabel.right
                horizontalAlignment: Text.AlignRight
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: updated
            }
        }

        Image {
            id: followedIcon
            visible: followedStatusLoaded
            anchors.left: askedAdUpdatedTimesRec.right
            anchors.top: askedAdUpdatedTimesRec.top
            anchors.leftMargin: Theme.paddingLarge - 5
            source: followed ? "image://theme/icon-l-favorite"
                             : "image://theme/icon-l-star"

            MouseArea {
                anchors.fill: parent
                enabled: ! infoBanner.visible()
                onClicked: {
                    if (amILoggedIn(qsTr("Please login to follow/un-follow questions!")))
                        followQuestion()
                }
            }
        }

        StatsRow {
            id: statsRow
            timesVisible: false
            parentWidth: parent.width -
                         askedAdUpdatedTimesRec.width -
                         followedIcon.width -
                         Theme.paddingMedium    // left of askedAdUpdatedTimesRec
            anchors.bottom: askedAdUpdatedTimesRec.bottom
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
        }
        // Voting buttons
        VotingButton {
            id: voteUpButton
            enabled: voteStatusLoaded
            visible: voteStatusLoaded
            anchors.bottom: statsRow.top
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge

            buttonType: voteUpButton.question_vote_up
            userLoggedIn: questionsModel.isUserLoggedIn()
            userNotifObject: infoBanner
            oppositeVoteButton: voteDownButton
            initialVotes: votes
            votingTargetId: qid
        }
        VotingButton {
            id: voteDownButton
            enabled: voteStatusLoaded
            visible: voteStatusLoaded
            anchors.top: statsRow.bottom
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge

            buttonType: voteUpButton.question_vote_down
            userLoggedIn: questionsModel.isUserLoggedIn()
            userNotifObject: infoBanner
            oppositeVoteButton: voteUpButton
            initialVotes: votes
            votingTargetId: qid
        }
        Item {
            id: filler
            width: 1
            anchors.left: parent.left
            anchors.top: askedAdUpdatedTimesRec.bottom
            height: hasTags() ? Theme.paddingLarge : 0
        }

        ItemFlowColumn {
            id: tagsColumn
            itemsArrayModel: tagsArray
            anchors.top: filler.bottom
            anchors.left: parent.left
            anchors.right: voteDownButton.left

        }

        Column {
            id: questionTextContentColumn
            width: parent.width
            height: childrenRect.height
            anchors.top: (voteDownButton.y > tagsColumn.y) ? voteDownButton.bottom : tagsColumn.bottom

            Item {
                width: 1
                height: hasTags() ? Theme.paddingLarge : 0
            }

            ShowRichTextWithLinkActions {
                id: questionText
                fontSize: getPageTextFontSize()
                text: page.text
                textBanner: infoBanner
                parentFlickable: contentFlickable
            }

            Image {
                id: textSelectButton
                visible: textSelectionEnabled
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                source: "image://theme/icon-m-clipboard"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        questionText.toggleTextSelectMode()
                    }
                }
            }
            Item {
                width: 1
                height: Theme.paddingLarge
            }
            Item {
                width: 1
                height: Theme.paddingLarge
            }

            MouseArea {
                id: clicker;
                width: parent.width
                height: 40
                onClicked: { loadAnswersAndComments() }
                Image {
                    source: "qrc:/qml/images/arrow-right.png"
                    anchors.leftMargin: Theme.paddingMedium
                    rotation: answersAndCommentsOpen ? +90 : 0
                    anchors.left: parent.left
                    Behavior on rotation { NumberAnimation { duration: 180; } }
                }
                Label {
                    anchors.centerIn: parent
                    font.pixelSize: Theme.fontSizeMedium
                    text: qsTr("Answers and Comments") + (answersAndCommentsOpen ? " (" + rssFeedModel.count + ")" : "")
                }
            }
            Item {
                width: 1
                height: Theme.paddingExtraLarge
            }

            Repeater {
                id: answersAndCommentsList
                property string commentRelatedToquestionOrAnswer: qid
                visible: finalRssModel.ready && answersAndCommentsOpen
                width: parent.width
                height: childrenRect.height
                anchors.left: parent.left
                anchors.right: parent.right
                model: finalRssModel
                clip: true
                delegate: AnswersAndCommentsDelegate { }
                onItemAdded: {
                    if (item.isAnswer()) {
                        commentRelatedToquestionOrAnswer = item.getAnswerOrCommentNumber()
                        //console.log("Answer added, answerNbr: " + item.getAnswerOrCommentNumber())
                        get_answer_data(item.getAnswerOrCommentNumber(), item)
                    }
                    else { // Comment
                        item.setRelatedAnswerNumber(commentRelatedToquestionOrAnswer)
                        get_comment_data(item.getAnswerOrCommentNumber(), item, pressSeeMoreCommentsButton)
                    }

                    if (index === (pagingListModel.pageStopIndex - 1)) {
                        urlLoading = false
                        endTime = Date.now()
                        console.log("AnswersAndComments load time: " + (endTime - startTime))
                    }
                }
            }
            Item {
                width: 1
                height: Theme.paddingExtraLarge
            }
        }
        ScrollDecorator { }
        onAtYEndChanged: {
            //console.log("at END. " + contentY + "," + parent.height + "," + height + "," + atYEnd)
            if (atYEnd && contentY >= parent.height && answersAndCommentsOpen) {
                if (contentY > 0 && parent.height > 0) {
                    console.log("At end of page, load next answers/comments")
                    rssFeedModel.fillRssModel(finalRssModel)
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
                    questionTitleItem.height +
                    titlePadding.height +
                    askedAdUpdatedTimesRec.height +
                    voteUpButton.height +
                    voteDownButton.height +
                    filler.height +
                    tagsColumn.height
        }
    }
    SearchBanner {
        id: searchBanner
        foreground: contentFlickable
        mainFlickable: contentFlickable
        pageMainTextElement: questionText
        pageDynamicTextModelElement: answersAndCommentsList
    }
}

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
    property string created: questionsModel.get(index).created_date
    property string updated: questionsModel.get(index).updated_date
    property string userId: questionsModel.get(index).author_id
    property string userName: questionsModel.get(index).author
    property string userPageUrl: questionsModel.get(index).author_page_url
    property string votes: questionsModel.get(index).votes.toString()
    property string answer_count: questionsModel.get(index).answer_count
    property string view_count: questionsModel.get(index).view_count
    property string tags: questionsModel.get(index).tags
    property var tagsArray: null
    property string userKarma: ""
    property string userAvatarUrl: ""
    property bool upVoteOn: false
    property bool downVoteOn: false
    property bool voteStatusLoaded: false
    property bool textSelectionEnabled: false
    property bool followedStatusLoaded: false
    property bool followed: false
    property var startTime
    property var endTime
    property int landScapeMode: phoneOrientation
    property int userPicSize: pageSmallestSideLenght / 5

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

    RssFeedModel {
        id: rssFeedModel
        rssFeedUrl: siteBaseUrl + "/feeds/question/" + qid + "/"
    }

    function goToItem(idx) {
        var props = {
            "index": idx
        };
        if (pageStack.currentPage.objectName === "AnswerPage") {
            pageStack.navigateBack(PageStackAction.Immediate)
        }
        questionsModel.loadQuestionViewpage(questionsModel.getQuestionIdOfIndex(idx),
                                            idx,
                                            true,
                                            props)
    }

    // Set some properties
    // after answer got from asyncronous (get_user) http request.
    function setUserData(user_data) {
        userKarma = user_data.reputation
        userAvatarUrl = usersModel.changeImageLinkSize(user_data.avatar_url, userPicSize) //match this size to userPic size
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
            actionButtons.setVoteStatuses(up, down)
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
        tagsArray = getTagsArray()
        contentFlickable.focus = true // Set focus for enabling keyboard presses
        rssFeedModel.startLoadingRss()
    }

    onUserIdChanged: {
        console.log("UserId Changed to: " + userId)
        usersModel.get_user(userId, setUserData)
    }

    onLandScapeModeChanged: {
        if (landScapeMode === Orientation.Landscape ||
                landScapeMode === Orientation.LandscapeInverted) {
            console.log("turning to landscape mode")
        }
        else {
            console.log("turning to normal mode")
        }
    }


    onStatusChanged: {
        if (status === PageStatus.Active && (url !== "" || questionsModel.externalUrl !== ""))
        {
            if (questionsModel.openQuestionlOnJolla2getherApp) {
                questionsModel.openQuestionlOnJolla2getherApp = false
                var props = {
                    "index": questionsModel.getInAppClickedQuestionIndex()
                }
                unattachWebview()
                questionsModel.loadQuestionViewpage(questionsModel.questionIdOfClickedTogetherLink,
                                                    questionsModel.questionsCount,
                                                    true,
                                                    props)
            }
            else {
                console.log("attach back: " + url)
                siteURL = page.url
                attachWebview()
                questionsModel.questionIdOfClickedTogetherLink = ""

                if (questionsModel.openExternalLinkOnWebview) {
                    questionsModel.openExternalLinkOnWebview = false
                    siteURL = questionsModel.externalUrl
                    questionsModel.externalUrl = ""
                    console.log("Opening external url: " + siteURL)
                    pageStack.navigateForward()
                }
            }
            rssFeedModel.unloadAnswer()
        }
    }

    SilicaFlickable {
        id: contentFlickable
        anchors.fill: parent
        contentHeight: heighBeforeTextContent() +
                       questionTextContentColumn.height
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
            anchors.right: parent.right
            height: userPic.height + Theme.paddingLarge
            //width: userPic.width + (userNameLabel.width > userKarmaLabel.width ? userNameLabel.width : userKarmaLabel.width)
            width: userPic.width + Theme.paddingMedium
            Label {
                id: userNameLabel
                anchors.top: pageHeader.top
                anchors.right: userPic.left
                anchors.topMargin: Theme.paddingLarge
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
                anchors.rightMargin: Theme.paddingLarge
                anchors.topMargin: Theme.paddingLarge
                width: userPicSize
                height: userPicSize
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
//        PullDownMenu {
//            id: pullDownMenu
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

//            MenuItem {
//                text: qsTr("Search...")
//                onClicked: {
//                    searchBanner.show()
//                }
//            }
//        }
        Item {
            id: questionTitleItem
            anchors.top: pageHeader.verticalCenter
            anchors.topMargin: Theme.paddingLarge
            anchors.left: parent.left
            anchors.right: pageHeader.left
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
                font.pixelSize: Theme.fontSizeMedium
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
                text: created
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
        StatsRow {
            id: statsRow
            timesVisible: false
            anchors.bottom: askedAdUpdatedTimesRec.bottom
            anchors.left: askedAdUpdatedTimesRec.right
            anchors.rightMargin: Theme.paddingMedium
            anchors.leftMargin: Theme.paddingLarge * 2
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
            visible: hasTags()
            itemsArrayModel: tagsArray
            anchors.top: filler.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }
        ButtonPanel {
            id: actionButtons
            visible: followedStatusLoaded
            width: parent.width
            anchors.top: getTop()
            anchors.topMargin: Theme.paddingLarge
            anchors.bottomMargin: Theme.paddingLarge
//            anchors.leftMargin: Theme.paddingLarge * 3
//            anchors.rightMargin: Theme.paddingLarge * 3

            // Search button
            customButton1.icon.source: "image://theme/icon-m-search"
            customButton1.onClicked: {
                searchBanner.show()
            }
            customButtom1LabelText: qsTr("Search")

            // Followed button
            customButton2.icon.source: followed ? "image://theme/icon-m-favorite-selected"
                                                : "image://theme/icon-m-favorite"
            customButton2.enabled: ! infoBanner.visible()
            customButton2.onClicked: {
                if (amILoggedIn(qsTr("Please log in to follow/un-follow questions!")))
                    followQuestion()
            }
            customButtom2LabelText: qsTr("Follow")

            // Vote buttons
            voteButtonsTargetId: qid
            voteButttonsInitialVote: votes
            voteUpButton.buttonType: voteUpButton.question_vote_up
            voteDownButton.buttonType: voteDownButton.question_vote_down
            isMyOwnPost: questionsModel.isMyOwnQuestion(index)

            function getTop() {
                //console.log("tagsColumn.y: " + tagsColumn.y + tagsColumn.height + ", pageHeader.y: " + pageHeader.y + pageHeader.height)
                return tagsColumn.y + tagsColumn.height > pageHeader.y + pageHeader.height ? tagsColumn.bottom : pageHeader.bottom
            }
        }
        Column {
            id: questionTextContentColumn
            width: parent.width
            height: childrenRect.height
            anchors.top: actionButtons.bottom
            Item {
                width: 1
                height: Theme.paddingLarge
            }

            // Show question status (closed/answered)
            Label {
                id: questionStatusLabel
                visible: questionsModel.getQuestionClosedAnsweredStatusAsText(index) !== ""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                font.pixelSize: getPageTextFontSize()
                width: parent.width
                text: questionsModel.getQuestionClosedAnsweredStatusAsText(index)
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
                height: Theme.paddingLarge * 3
            }

            RssFeedRepeater {
                id: commentsFeed
                visible: rssFeedModel.ready
                buttonVisible: rssFeedModel.pagingModelQuestionComments.ready && rssFeedModel.getTotalQuestionCommentsCount() > 0
                modelReady: rssFeedModel.pagingModelQuestionComments.ready
                buttonActivated: rssFeedModel.questionCommentsListOpen && rssFeedModel.getQuestionCommentsCount() > 0
                buttonLabelText: getButtonText()
                repeaterModel: rssFeedModel.questionCommentsRssModel
                repeaterDelegate: CommentsDelegate { loadCommentData: followedStatusLoaded
                    relatedQuestionOrAnswerNumber: qid }
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
                    if (!rssFeedModel.pagingModelQuestionComments.ready) {
                        return qsTr("Loading Comments...")
                    }
                    if (rssFeedModel.getTotalQuestionCommentsCount() > 0) {
                        var commentsText = rssFeedModel.getTotalQuestionCommentsCount() === 1 ? qsTr(" Comment") : qsTr(" Comments")
                        return (!rssFeedModel.questionCommentsListOpen ? rssFeedModel.getTotalQuestionCommentsCount() : "") + commentsText + (rssFeedModel.questionCommentsListOpen ? " (" + rssFeedModel.getQuestionCommentsCount() + "/" + rssFeedModel.getTotalQuestionCommentsCount() + ")" : "")
                    }
                    else {
                        return qsTr("No Comments")
                    }
                }
            }

            Item {
                width: 1
                height: Theme.paddingLarge * 2
            }

            RssFeedRepeater {
                id: answersFeed
                visible: rssFeedModel.ready
                buttonVisible: rssFeedModel.pagingModelAnswers.ready && answer_count !== "0"
                modelReady: rssFeedModel.pagingModelAnswers.ready
                buttonActivated: rssFeedModel.answersListOpen && rssFeedModel.getAnswersCount() > 0
                buttonLabelText: getButtonText()
                repeaterModel: rssFeedModel.answersRssModel
                repeaterDelegate: AnswerDelegate {}
                onButtonPressed: {
                    rssFeedModel.openAnswersOrCommentsRssFeedList(true)
                }
                onSortAscPressed: {
                    rssFeedModel.triggerFeedWorker(rssFeedModel.answerFilter, rssFeedModel.sORT_ASC)
                }
                onSortDescPressed: {
                    rssFeedModel.triggerFeedWorker(rssFeedModel.answerFilter, rssFeedModel.sORT_DESC)
                }
                function getButtonText() {
                    if (!rssFeedModel.pagingModelAnswers.ready) {
                        return qsTr("Loading Answers...")
                    }
                    if (answer_count !== "0") {
                        var answerText = answer_count === "1" ? qsTr(" Answer") : qsTr(" Answers")
                        return (!rssFeedModel.answersListOpen ? answer_count : "") + answerText + (rssFeedModel.answersListOpen ? " (" + rssFeedModel.getAnswersCount() + "/" + rssFeedModel.getTotalAnswersCount() + ")" : "")
                    }
                    else {
                        return qsTr("No Answers")
                    }
                }
            }
            Label {
                id: loadingRss
                visible: !rssFeedModel.ready
                anchors.horizontalCenter: parent.horizontalCenter
                font.italic: true
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("Loading Comments and Answers...")
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }
        }
        ScrollDecorator { }
        onAtYEndChanged: {
            //console.log("at END. " + contentY + "," + parent.height + "," + height + "," + atYEnd)
            if (atYEnd && contentY >= parent.height && (rssFeedModel.answersListOpen || rssFeedModel.questionCommentsListOpen)) {
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
                    questionTitleItem.height +
                    titlePadding.height +
                    askedAdUpdatedTimesRec.height +
                    actionButtons.height +
                    filler.height +
                    tagsColumn.height
        }
    }

    SearchBanner {
        id: searchBanner
        foreground: contentFlickable
        mainFlickable: contentFlickable
        pageMainTextElement: questionText
        pageDynamicTextModelElement: commentsFeed.feedRepeater
    }
}

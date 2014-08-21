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
    property bool answersAndCommentsLoaded: false
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

    function loadAnswersAndComments() {
        startTime = Date.now()
        if (!answersAndCommentsLoaded) {
            urlLoading = true
            rssFeedModel.source = rssFeedUrl
            answersAndCommentsLoaded = true
        }
        if (answersAndCommentsOpen) {
            answersAndCommentsOpen = false
            rssFeedModel.initRssModel()
        }
        else {
            answersAndCommentsOpen = true
            rssFeedModel.fillRssModel(finalRssModel)
        }
    }


    // Set some properties
    // after answer got from asyncronous (get_user) http request.
    function setUserData(user_data) {
        userKarma = user_data.reputation
        userAvatarUrl = "http:" + usersModel.changeImageLinkSize(user_data.avatar, 100) //match this size to userPic size
        console.log("avatar: "+userAvatarUrl)
    }
    function getLabelMaxWidth() {
        return (askedLabel.paintedWidth + askedValue.paintedWidth) >
                (updatedLabel.paintedWidth + updatedValue.paintedWidth) ?
                    (askedLabel.width + askedValue.width) : (updatedLabel.width + updatedValue.width)
    }
    function getTagsArray() {
        return tags.split(",")
    }

    function votingResultsCallback(up, down) {
        upVoteOn = up
        downVoteOn = down
        voteDownButton.refreshSource()
        voteUpButton.refreshSource()
        voteStatusLoaded = true
    }

    function setVotesToQuestionModel(votes) {
        questionsModel.set(index, {"votes": votes})
    }

    function question_vote_up(question_id) {
        var script = "document.getElementById('question-img-upvote-" + question_id + "').click();"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script, function(result) {
            if (downVoteOn)
                upVoteOn = false
            else
                upVoteOn = true
            downVoteOn = false
            voteUpButton.refreshSource()
            voteDownButton.refreshSource()
            setVotesToQuestionModel(votes + 1)
            console.log("Voted UP question " + question_id + ", result: " + result)
        })
    }
    function question_vote_down(question_id) {
        var script = "document.getElementById('question-img-downvote-" + question_id + "').click();"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            if (upVoteOn)
                downVoteOn = false
            else
                downVoteOn = true
            upVoteOn = false
            voteDownButton.refreshSource()
            voteUpButton.refreshSource()
            setVotesToQuestionModel(votes - 1)
            console.log("Voted DOWN question " + question_id + ", result: " + result)
        })
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
        contentHeight: pageHeader.height +
                       questionTitleItem.height +
                       titlePadding.height +
                       askedAdUpdatedTimesRec.height +
                       voteUpButton.height +
                       voteDownButton.height +
                       filler.height +
                       tagsColumn.height +
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
                font.pixelSize: Theme.fontSizeExtraSmall
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
            //
            // Disabled text selection feature as copy to system clipboard seems not to work constantly
            //
            enabled: false
            visible: false
            MenuItem {
                text: qsTr("Show text selection buttons")
                visible: !textSelectionEnabled
                onClicked: {
                    textSelectionEnabled = true
                }
            }
            MenuItem {
                text: qsTr("Hide text selection buttons")
                visible: textSelectionEnabled
                onClicked: {
                    textSelectionEnabled = false
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
        Image {
            id: voteUpButton
            enabled: voteStatusLoaded
            visible: voteStatusLoaded
            function refreshSource() {
                voteUpButton.source = upVoteOn ? "qrc:/qml/images/arrow-right-vote-up.png" : "qrc:/qml/images/arrow-right.png"
            }
            anchors.bottom: statsRow.top
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            source: upVoteOn ? "qrc:/qml/images/arrow-right-vote-up.png" : "qrc:/qml/images/arrow-right.png"
            rotation: -90
            scale: 1.2
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    if (questionsModel.isUserLoggedIn()) {
                        if (!upVoteOn)
                            voteUpButton.source = "qrc:/qml/images/arrow-right-pressed.png"
                        else {
                            //notif to user
                            infoBanner.showText(qsTr("Already voted up!"))
                        }
                    }
                    else {
                        infoBanner.showText(qsTr("Please login to vote!"))
                    }
                }
                onReleased: {
                    if (!upVoteOn && questionsModel.isUserLoggedIn()) {
                        voteUpButton.refreshSource()
                        console.log("voting up")
                        question_vote_up(qid)
                    }
                }
            }
        }
        Image {
            id: voteDownButton
            enabled: voteStatusLoaded
            visible: voteStatusLoaded
            function refreshSource() {
                voteDownButton.source = downVoteOn ? "qrc:/qml/images/arrow-right-vote-down.png" : "qrc:/qml/images/arrow-right.png"
            }
            anchors.top: statsRow.bottom
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            source: downVoteOn ? "qrc:/qml/images/arrow-right-vote-down.png" : "qrc:/qml/images/arrow-right.png"
            rotation: +90
            scale: 1.2
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    if (questionsModel.isUserLoggedIn()) {
                        if (!downVoteOn)
                            voteDownButton.source = "qrc:/qml/images/arrow-right-pressed.png"
                        else {
                            //notif to user
                            infoBanner.showText(qsTr("Already voted down!"))
                        }
                    }
                    else {
                        infoBanner.showText(qsTr("Please login to vote!"))
                    }
                }
                onReleased: {
                    if (!downVoteOn && questionsModel.isUserLoggedIn()) {
                        voteDownButton.refreshSource()
                        console.log("voting down")
                        question_vote_down(qid)
                    }
                }
            }
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
                visible: finalRssModel.ready && answersAndCommentsOpen
                width: parent.width
                height: answersAndCommentsOpen ? childrenRect.height : 0
                anchors.left: parent.left
                anchors.right: parent.right
                model: answersAndCommentsOpen ? finalRssModel : undefined
                clip: true
                delegate: AnswersAndCommentsDelegate { }
                onItemAdded: {
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
    }
}

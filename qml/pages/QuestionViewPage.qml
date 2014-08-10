import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0
import "../components"

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
    property string commentFilter: "comment"
    property string answerFilter: "answer"
    property bool answersAndCommentsOpen: false
    property bool answersAndCommentsLoaded: false
    property string rssFeedUrl: siteBaseUrl + "/feeds/question/" + qid + "/"
    property bool upVoteOn: false
    property bool downVoteOn: false
    property bool voteStatusLoaded: false
    property bool userLoggedIn: false
    property bool textSelectionEnabled: false


    InfoBanner {
        id: infoBanner
    }

    ListModel {
        id: rssModel
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
    XmlListModel {
        id: rssModelOriginal
        source: ""
        query: "/rss/channel/item[contains(lower-case(child::category),lower-case(\""+commentFilter+"\")) or contains(lower-case(child::category),lower-case(\""+answerFilter+"\"))]"
        //namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom';"

        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "link"; query: "link/string()" }
        XmlRole { name: "description"; query: "description/string()" }
        XmlRole { name: "category"; query: "category/string()" }
        XmlRole { name: "pubDate"; query: "pubDate/string()"; isKey: true }
        onStatusChanged:{
            console.debug("feedSource: "+source)
            if (status === XmlListModel.Ready) {
                console.debug("feed itemcount ready: "+rssModelOriginal.count)
                sortCommentsByTime(rssModelOriginal, pagingListModel)
                fillRssModel(rssModel)
                rssModel.ready = true
                urlLoading = false
            }
            if (status === XmlListModel.Error) {
                urlLoading = false
            }
        }
    }
    function sortCommentsByTime(sourceModel, targetModel) {
        var n;
        for (n=0; n < sourceModel.count; n++)
        {
            if (sourceModel.get(n).category === commentFilter) {
                add2ListModel(sourceModel, sortModel, n)
            }
            else {  // Answer
                // Add here comments sorted by time
                addSortedComments(targetModel)
                add2ListModel(sourceModel, targetModel, n)
            }
        }
        // copy possible rest of comments
        addSortedComments(targetModel)
    }
    function addSortedComments(targetModel) {
        sortListModel(sortModel)
        copyModel(sortModel, targetModel)
        sortModel.clear()
    }
    function fillRssModel(listModel)
    {
        var n;
        pagingListModel.pageStopIndex = pagingListModel.currentIndex + pagingListModel.pageSize
        if (pagingListModel.pageStopIndex > pagingListModel.count)
            pagingListModel.pageStopIndex = pagingListModel.count
        for (n=pagingListModel.currentIndex; n < pagingListModel.pageStopIndex; n++)
        {
            urlLoading = true
            add2ListModel(pagingListModel, listModel, n)
            pagingListModel.currentIndex++
        }
    }
    function initRssModel() {
        rssModel.clear()
        pagingListModel.currentIndex = 0
        pagingListModel.pageStopIndex = 0
    }
    function sortListModel(listModel) {
        var n;
        var i;
        for (n=0; n < listModel.count; n++)
            for (i=n+1; i < listModel.count; i++)
            {
                var itemTime = questionsModel.rssPubDate2Seconds(listModel.get(n).pubDate)
                var nextItemTime = questionsModel.rssPubDate2Seconds(listModel.get(i).pubDate)
                if (itemTime > nextItemTime)
                {
                    listModel.move(i, n, 1);
                    n=0;
                }
            }
    }
    function copyModel(source, target) {
        var i;
        for (i=0; i < source.count; i++) {
            add2ListModel(source, target, i)
        }
    }
    function add2ListModel(sourceModel, toModel, index) {
        toModel.append({"title":          sourceModel.get(index).title,
                           "link":           sourceModel.get(index).link,
                           "description":    sourceModel.get(index).description,
                           "category":       sourceModel.get(index).category,
                           "pubDate":        sourceModel.get(index).pubDate})
    }

    function goToItem(idx) {
        var props = {
            "index": idx
        };
        pageStack.replace("QuestionViewPage.qml", props);
    }

    function loadAnswersAndComments() {
        if (!answersAndCommentsLoaded) {
            urlLoading = true
            rssModelOriginal.source = rssFeedUrl
            answersAndCommentsLoaded = true
        }
        if (answersAndCommentsOpen) {
            answersAndCommentsOpen = false
            initRssModel()
        }
        else {
            answersAndCommentsOpen = true
            fillRssModel(rssModel)
        }
    }


    // Set some properties
    // after answer got from asyncronous (get_user) http request.
    function setUserData(user_data) {
        userKarma = user_data.reputation
        userAvatarUrl = "http:" + usersModel.changeImageLinkSize(user_data.avatar, 100) //match this size to userPic size
        console.log("avatar: "+userAvatarUrl)
    }
    function selectLabelRight() {
        return (askedLabel.paintedWidth + askedValue.paintedWidth) >
                (updatedLabel.paintedWidth + updatedValue.paintedWidth) ?
                    askedValue.right : updatedValue.right
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
    function getPageTextFontSize() {
        //return Theme.fontSizeTiny
        //return Theme.fontSizeSmall // Default
        //return Theme.fontSizeMedium
        //return Theme.fontSizeLarge
        //return Theme.fontSizeExtraLarge
        return appSettings.question_view_page_font_size_value
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
            userLoggedIn = questionsModel.isUserLoggedIn()
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
                       timesAndStatsRec.height +
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
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            height: childrenRect.height

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                horizontalAlignment: Text.AlignLeft
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

        Rectangle {
            id: timesAndStatsRec
            anchors.top: questionTitleItem.bottom
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            color: "transparent"
            width: getLabelMaxWidth() +
                   fillRectangel.width +
                   votesRectangle.width +
                   answersRectangle.width +
                   viewsRectangle.width
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

            // Fill some space before statics rectangles
            Rectangle {
                id: fillRectangel
                anchors.left: selectLabelRight()
                color: "transparent"
                width: 15
                height: 40
            }
            // Answers
            Rectangle {
                id: answersRectangle
                anchors.left: fillRectangel.right
                anchors.bottom: updatedLabel.bottom
                color: "transparent"
                smooth: true
                //border.width: 1
                width: 80
                height: 40
                radius: 10
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    color: "orange"
                    text: answer_count
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: qsTr("answers")
                }
            }
            // Views
            Rectangle {
                id: viewsRectangle
                anchors.left: answersRectangle.right
                anchors.bottom: updatedLabel.bottom
                color: "transparent"
                smooth: true
                //border.width: 1
                width: 80
                height: 40
                radius: 10
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    color: "red"
                    text: view_count
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: qsTr("views")
                }
            }
        }

        // Voting buttons
        Image {
            id: voteUpButton
            enabled: voteStatusLoaded
            visible: voteStatusLoaded
            function refreshSource() {
                voteUpButton.source = upVoteOn ? "qrc:/qml/images/arrow-right-vote-up.png" : "qrc:/qml/images/arrow-right.png"
            }
            anchors.top: timesAndStatsRec.top
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            anchors.leftMargin: Theme.paddingLarge
            //anchors.bottomMargin: Theme.paddingLarge
            source: upVoteOn ? "qrc:/qml/images/arrow-right-vote-up.png" : "qrc:/qml/images/arrow-right.png"
            rotation: -90
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    if (userLoggedIn) {
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
                    if (!upVoteOn && userLoggedIn) {
                        voteUpButton.refreshSource()
                        console.log("voting up")
                        question_vote_up(qid)
                    }
                }
            }
        }
        // Votes
        Rectangle {
            id: votesRectangle
            anchors.top: voteUpButton.bottom
            anchors.horizontalCenter: voteUpButton.horizontalCenter
            color: "transparent"
            smooth: true
            width: 80
            height: 40
            radius: 10
            Label {
                font.pixelSize: Theme.fontSizeTiny
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                visible: voteStatusLoaded
                color: "lightgreen"
                text: votes
            }
            Label {
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                visible: voteStatusLoaded
                text: qsTr("votes")
            }
        }
        Image {
            id: voteDownButton
            enabled: voteStatusLoaded
            visible: voteStatusLoaded
            function refreshSource() {
                voteDownButton.source = downVoteOn ? "qrc:/qml/images/arrow-right-vote-down.png" : "qrc:/qml/images/arrow-right.png"
            }
            anchors.top: votesRectangle.bottom
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            anchors.leftMargin: Theme.paddingLarge
            //anchors.topMargin: Theme.paddingLarge
            source: downVoteOn ? "qrc:/qml/images/arrow-right-vote-down.png" : "qrc:/qml/images/arrow-right.png"
            rotation: +90
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    if (userLoggedIn) {
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
                    if (!downVoteOn && userLoggedIn) {
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
            anchors.top: timesAndStatsRec.bottom
            height: Theme.paddingMedium
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
            anchors.top: tagsColumn.bottom

            Item {
                width: 1
                height: Theme.paddingLarge
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
                    text: qsTr("Answers and Comments") + (answersAndCommentsOpen ? " (" + rssModelOriginal.count + ")" : "")
                }
            }
            Item {
                width: 1
                height: Theme.paddingLarge
            }

            Repeater {
                id: answersAndCommentsList
                visible: rssModel.ready && answersAndCommentsOpen
                width: parent.width
                height: answersAndCommentsOpen ? childrenRect.height : 0
                anchors.left: parent.left
                anchors.right: parent.right
                model: answersAndCommentsOpen ? rssModel : undefined
                clip: true
                delegate: AnswersAndCommentsDelegate { }
                onItemAdded: {
                    if (index === (pagingListModel.pageStopIndex - 1)) {
                        urlLoading = false
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
            //console.log("at END. " + contentY + "," + parent.height + "," + height + "," + atYEnd)
            if (atYEnd && contentY >= parent.height && answersAndCommentsOpen) {
                if (contentY > 0 && parent.height > 0) {
                    console.log("At end of page, load next answers/comments")
                    fillRssModel(rssModel)
                }
            }
        }
    }
}

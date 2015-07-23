import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

ListItem  {
    id: answerListItem
    anchors.left: parent.left
    anchors.right: parent.right
    width: parent.width
    anchors.leftMargin: Theme.paddingLarge
    anchors.rightMargin: Theme.paddingMedium
    contentHeight: answersContentColumn.height
    height: contentHeight
    property string answerUserName: "" // Relevant for answer wiki posts where answer updating user is set here

    onClicked: {
        unattachWebview()
        var answerId = getAnswerOrCommentNumber()
        var props = {
            "questionIndex": page.index, // question index from questionviewpage not the answer index
            "answerId": answerId,
            "text": description,
            "pubDate": pubDate,
            "rssFeedModel": rssFeedModel
        };
        rssFeedModel.prepareForAnswer(answerId)
        pageStack.push(Qt.resolvedUrl("AnswerPage.qml"), props)
    }

    Column {
        id: answersContentColumn
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
            height: childrenRect.height
            Column {
                id: titleColumn
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
                        width: 1
                    }                    
                }
            }
            Item {
                id: fillSpace
                height: 1
                width: parent.width - titleColumn.width
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

        Row {
            width: parent.width
            Label {
                id: answerText
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                width: parent.width
                font.pixelSize: getTextSize()
                text: questionsModel.wiki2Html(description)
                clip: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                maximumLineCount: 4
            }
        }
        Item {
            id: filler
            width: 1
            anchors.left: parent.left
            height: Theme.paddingLarge
        }
    }
    function getTextSize() {
        //return Theme.fontSizeTiny // Default
        //return Theme.fontSizeSmall
        //return Theme.fontSizeMedium
        //return Theme.fontSizeLarge
        //return Theme.fontSizeExtraLarge
        return appSettings.question_view_page_answers_and_comments_font_size_value
    }
    function isAnswer() {
        if (category == rssFeedModel.answerFilter)
            return true
        return false
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
    function getTitle() {
        return "<font color=\"orange\">Answer</font> by"
    }
    function getOrigUserFromTitle() {
        return title.split(" ")[2]
    }
    // E.g. "Comment by tace ..."
    function getUser() {
        return updatedAnswerUser() ? answerUserName : getOrigUserFromTitle()
    }
    function getUserFormatted() {
        return updatedAnswerUser() ?  " " + getOrigUserFromTitle() + " Updated by" : " <b>" + getUser() + "</b>"
    }
    function getTimeString() {
        return "<font size=\"1\">" + questionsModel.rssPubdate2ElapsedTimeString(pubDate) + "</font>"
    }
    function getTimeForTitle() {
        return getTimeString()
    }
    // for wiki posts answers can be updated by anyone and then answered user changes
    function updatedAnswerUser() {
        if ((answerUserName !== "") && (answerUserName !== getOrigUserFromTitle()))
            return true
        return false
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
}

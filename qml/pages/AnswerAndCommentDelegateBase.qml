import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

ListItem  {
    anchors.left: parent.left
    anchors.right: parent.right
    width: parent.width
    anchors.leftMargin: Theme.paddingLarge
    anchors.rightMargin: Theme.paddingMedium
    height: contentHeight
    property string answerId
    property string answerUserName: "" // Relevant for answer wiki posts where answer updating user is set here

    function getTextSize() {
        //return Theme.fontSizeTiny // Default
        //return Theme.fontSizeSmall
        //return Theme.fontSizeMedium
        //return Theme.fontSizeLarge
        //return Theme.fontSizeExtraLarge
        return appSettings.question_view_page_answers_and_comments_font_size_value
    }
//    function getPlainText() {
//        return answerCommentText.getPlainText()
//    }
//    function selectAndMovetoText(start, end) {
//        return answerCommentText.selectAndMovetoText(start, end)
//    }
//    function resetSearchTextSelection() {
//        answerCommentText.resetTextSelection()
//    }
    function isAnswer() {
        if (category === rssFeedModel.answerFilter)
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
        return updatedAnswerUser() ?  " " + getOrigUserFromTitle() + " Updated by" : " <b>" + getUser() + "</b>"
    }
    function getTimeForTitle() {
        return "<font size=\"1\">" + questionsModel.rssPubdate2ElapsedTimeString(pubDate) + "</font>"
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

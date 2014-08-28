import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

ListItem  {
    anchors.left: parent.left
    anchors.right: parent.right
    width: parent.width
    anchors.leftMargin: Theme.paddingLarge
    anchors.rightMargin: Theme.paddingMedium
    contentHeight: answersAndCommentsColumn.height
    height: contentHeight
    _showPress: false // Disable normal list item highlighting

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
            height: textSelectionEnabled ? textSelect.height : titleLabel.height
            Label {
                id: titleLabel
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: getTitle() + " <b>" + getUser() + "</b>   <font size=\"1\">(" + questionsModel.rssPubdate2ElapsedTimeString(pubDate) + ")</font>"
            }
            Image {
                id: textSelect
                visible: textSelectionEnabled
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                source: "image://theme/icon-m-clipboard"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        answerCommentText.toggleTextSelectMode()
                    }
                }
            }
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
    function getTitle() {
        if (isAnswer())
            return "<font color=\"orange\">Answer</font> by"
        return "<font size=\"1\">Comment by</font>"
    }

    // E.g. "Comment by tace ..."
    function getUser() {
        return title.split(" ")[2]
    }
}

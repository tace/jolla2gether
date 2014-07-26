import QtQuick 2.0
import Sailfish.Silica 1.0


ListItem  {
    anchors.left: parent.left
    anchors.right: parent.right
    width: parent.width
    anchors.leftMargin: Theme.paddingLarge
    anchors.rightMargin: Theme.paddingMedium
    contentHeight: answersAndCommentsColumn.height
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

        Label {
            id: titleLabel
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
            width: parent.width
            text: getTitle() + " <b>" + getUser() + "</b>   <font size=\"1\">(" + questionsModel.rssPubdate2ElapsedTimeString(pubDate) + ")</font>"
        }
        RescalingRichText {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium

            color: Theme.primaryColor
            fontSize: getTextSize()
            text: questionsModel.wiki2Html(description)

            onLinkActivated: {
                var props = {
                    "url": link
                }
                var dialog = pageStack.push(Qt.resolvedUrl("ExternalLinkDialog.qml"), props);
                dialog.accepted.connect(function() {
                    if (dialog.__browser_type === "webview") {
                        openExternalLinkOnWebview = true
                        externalUrl = link
                    }
                })
            }
        }

        Item {
            id: filler
            width: 1
            anchors.left: parent.left
            height: Theme.paddingLarge
        }
    }
    function isAnswer() {
        if (category == answerFilter)
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

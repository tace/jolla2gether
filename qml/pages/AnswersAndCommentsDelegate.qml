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
            text: getTitle() + " by <b>" + getUser() + "</b>   <b><font size=\"1\">(" + questionsModel.rssPubdate2ElapsedTimeString(pubDate) + ")</font></b>"
        }
        //        Label {
        //            id: descriptionLabel
        //            font.pixelSize: Theme.fontSizeTiny
        //            width: parent.width
        //            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        //            text: questionsModel.wiki2Html(description)
        //        }
        RescalingRichText {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium

            color: Theme.primaryColor
            fontSize: Theme.fontSizeTiny
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

        //        Label {
        //            id: pubDateLabel
        //            font.pixelSize: Theme.fontSizeTiny
        //            font.bold: true
        //            color: Theme.secondaryColor
        //            width: parent.width
        //            text: questionsModel.rssPubdate2ElapsedTimeString(pubDate)
        //        }
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
            return "Answer"
        return "Comment"
    }

    // E.g. "Comment by tace ..."
    function getUser() {
        return title.split(" ")[2]
    }
}

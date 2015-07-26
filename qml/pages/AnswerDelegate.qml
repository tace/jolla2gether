import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

AnswerAndCommentDelegateBase  {
    id: answerListItem
    contentHeight: answersContentColumn.height

    onClicked: {
        unattachWebview()
        var answerId = getAnswerOrCommentNumber()
        var props = {
            "questionIndex": page.index, // question index from questionviewpage not the answer index
            "answerId": answerId,
            "answerUser": getOrigUserFromTitle(),
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
}

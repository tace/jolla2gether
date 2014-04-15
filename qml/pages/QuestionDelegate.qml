import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem  {
    id: background
    anchors.left: ListView.left
    anchors.right: ListView.right
    width: parent.width
    contentHeight: titleText.lineCount > 1 ? Theme.itemSizeLarge : Theme.itemSizeSmall

    onClicked: {
        questionListView.currentIndex = index
        siteURL = url;
        pageStack.navigateForward();
    }

    function getTitleColor() {
        var color = Theme.primaryColor
        // If item selected either from list or Cover, make color highlighted
        if (background.highlighted ||
                (index === coverProxy.currentQuestion - 1)) {
            color = Theme.highlightColor
        }
        return color
    }
    function getStatusPrefixText() {
        var ret_text = ""
        if(closed) {
            ret_text = "<font color=\"lightgreen\" size=\"1\">[closed] </font>"
        }
        if (has_accepted_answer) {
            ret_text = ret_text + "<font color=\"orange\" size=\"1\">[answered] </font>"
        }
        return ret_text
    }
    function is2LinesForTitle() {
        if (appSettings.qUESTION_LIST_TITLE_SPACE_VALUE === appSettings.qUESTION_LIST_TITLE_SPACE_VALUE_ONE_LINE)
            return false
        if (appSettings.qUESTION_LIST_TITLE_SPACE_VALUE === appSettings.qUESTION_LIST_TITLE_SPACE_VALUE_2_LINES)
            return true
    }

    Label {
        id: titleText
        font.pixelSize: Theme.fontSizeSmall
        width: parent.width
        color: getTitleColor()
        font.bold: model.url === siteURL
        maximumLineCount: is2LinesForTitle() ? 2 : 1
        elide: is2LinesForTitle() ? Text.ElideRight : Text.ElideNone
        wrapMode: is2LinesForTitle() ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
        text: getStatusPrefixText() + title
    }
    Label {
        id: authorLabel
        anchors.top: titleText.bottom
        anchors.left: titleText.left
        font.pixelSize: Theme.fontSizeTiny
        text: author + "  "
    }

    // Fill some space before statics rectangles
    Rectangle {
        id: fillRectangel
        anchors.left: authorLabel.right
        anchors.top: authorLabel.top
        color: "transparent"
        width: background.width - authorLabel.width - timesRectangle.width - votesRectangle.width - answersRectangle.width - viewsRectangle.width
        height: 40
    }

    // Created and updated time strings
    Rectangle {
        id: timesRectangle
        anchors.left: fillRectangel.right
        anchors.top: fillRectangel.top
        color: "transparent"
        width: 200
        height: 40
        Label {
            font.pixelSize: Theme.fontSizeTiny
            anchors.top: parent.top
            anchors.right: parent.right
            text: "c: " + created
        }
        Label {
            font.pixelSize: Theme.fontSizeTiny
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            text: "u: " + updated
        }

        // Votes
        Rectangle {
            id: votesRectangle
            anchors.left: timesRectangle.right
            color: "transparent"
            smooth: true
            border.width: 1
            width: 60
            height: 40
            radius: 10
            Label {
                font.pixelSize: Theme.fontSizeTiny
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                color: "lightgreen"
                text: votes
            }
            Label {
                font.pixelSize: Theme.fontSizeTiny
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                text: "votes"
            }
        }

        // Answers
        Rectangle {
            id: answersRectangle
            anchors.left: votesRectangle.right
            color: "transparent"
            smooth: true
            border.width: 1
            width: 70
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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                text: "answers"
            }
        }

        // Views
        Rectangle {
            id: viewsRectangle
            anchors.left: answersRectangle.right
            color: "transparent"
            smooth: true
            border.width: 1
            width: 60
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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                text: "views"
            }
        }
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

ListItem  {
    id: background
    anchors.left: ListView.left
    anchors.right: ListView.right
    width: parent.width
    contentHeight: getListItemContentHeight() + getTagsColumnHeight() + getSeparatorHeight()
    menu: contextMenu
    property string tagsString: tags
    property var tagsArray: null


    onClicked: {
        questionListView.currentIndex = index
        siteURL = url;
        var props = {
            "index": questionListView.currentIndex
        };
        pageStack.push(Qt.resolvedUrl("QuestionViewPage.qml"), props)
    }

    function getListItemContentHeight() {
        var appsettingForTextSize = getTitleTextFontSize()
        var extraSpace = 20
        if (appsettingForTextSize >= Theme.fontSizeLarge) {
            if (appsettingForTextSize >= Theme.fontSizeExtraLarge)
                extraSpace += 20
            if (titleText.lineCount > 1)
                return Theme.itemSizeExtraLarge + extraSpace
            else
                return Theme.itemSizeLarge
        }
        if (appsettingForTextSize >= Theme.fontSizeMedium) {
            if (titleText.lineCount > 1)
                return Theme.itemSizeLarge + extraSpace
            else
                return Theme.itemSizeSmall + 10
        }
        if (appsettingForTextSize >= Theme.fontSizeSmall) {
            if (titleText.lineCount > 1)
                return Theme.itemSizeLarge + 7
            else
                return Theme.itemSizeSmall + 1
        }
        if (titleText.lineCount > 1) {
            return Theme.itemSizeSmall + 13
        }
        else {
            return Theme.itemSizeSmall - 11
        }
    }
    function isTagsShown() {
        if ((tagsString !== "") && appSettings.question_list_show_tags_value)
            return true
        return false
    }
    function getTagsColumnHeight() {
        if (isTagsShown()) {
            if (tagsFlowColumn.itemsArrayModel.length > 0)
                return tagsFlowColumn.height
        }
        return 0
    }
    function getSeparatorHeight() {
        if (appSettings.question_list_show_separator_line_value)
            return 1
        return 0
    }
    function getTitleTextFontSize() {
        //return Theme.fontSizeExtraLarge
        //return Theme.fontSizeLarge
        //return Theme.fontSizeMedium
        //return Theme.fontSizeSmall // Default
        //return Theme.fontSizeTiny
        return appSettings.question_list_title_font_size_value
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
    function getTagsArray(tags) {
        return tags.split(",")
    }

    Label {
        id: titleText
        font.pixelSize: getTitleTextFontSize()
        width: parent.width
        color: getTitleColor()
        font.bold: model.url === siteURL
        maximumLineCount: is2LinesForTitle() ? 2 : 1
        elide: is2LinesForTitle() ? Text.ElideRight : Text.ElideNone
        wrapMode: is2LinesForTitle() ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
        text: getStatusPrefixText() + title
    }
    ItemFlowColumn {
        id: tagsFlowColumn
        itemsArrayModel: tagsArray
        visible: isTagsShown()
        width: parent.width
        anchors.top: titleText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 0
        anchors.rightMargin: 0
    }

    Label {
        id: authorLabel
        anchors.top: isTagsShown() ? tagsFlowColumn.bottom : titleText.bottom
        anchors.left: parent.left
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.secondaryColor
        font.bold: true
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
            color: Theme.secondaryColor
            anchors.top: parent.top
            anchors.right: parent.right
            text: "c: " + created
        }
        Label {
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.secondaryColor
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
            //            border.width: 1
            //            border.color: "gray"
            width: 80
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
                color: Theme.secondaryColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                text: qsTr("votes")
            }
        }

        // Answers
        Rectangle {
            id: answersRectangle
            anchors.left: votesRectangle.right
            color: "transparent"
            smooth: true
            //            border.width: 1
            //            border.color: "gray"
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
            color: "transparent"
            smooth: true
            //            border.width: 1
            //            border.color: "gray"
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
    Separator {
        width: parent.width
        visible: appSettings.question_list_show_separator_line_value
        anchors.top: timesRectangle.bottom
        horizontalAlignment: Qt.AlignCenter
        color: Theme.secondaryHighlightColor
        //height: 1
    }


    // context menu is activated with long press
    Component {
        id: contextMenu
        ContextMenu {
            MenuItem {
                text: qsTr("Copy url to clipboard")
                onClicked: Clipboard.text = url
            }
            MenuItem {
                visible: !userIdSearch  // disable rerursive user selections
                text: qsTr("All " + author + "'s questions")
                onClicked: {
                    questionListView.currentIndex = index
                    questionsModel.cacheModel()

                    if (appSettings.question_reset_search_on_listing_user_questions_value)
                        questionsModel.resetSearchCriteria()

                    questionsModel.setUserIdSearchCriteria(author_id)
                    questionsModel.pageHeader = author + "'s questions"
                    questionsModel.refresh()
                    pageStack.push(Qt.resolvedUrl("QuestionsPage.qml"), {userIdSearch: true})
                }
            }
        }
    }
    Component.onCompleted: {
        tagsArray = getTagsArray(tagsString)
    }
}

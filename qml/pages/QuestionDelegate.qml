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

    Keys.onReturnPressed: {
        clicked(MouseArea)
    }

    onClicked: {
        questionListView.currentIndex = index
        siteURL = url;
        var props = {
            "index": questionListView.currentIndex
        };
        unattachWebview()
        questionsModel.loadQuestionViewpage(id,
                                            index,
                                            false,
                                            props)
    }

    function getListItemContentHeight() {
        var appsettingForTextSize = getTitleTextFontSize()
        if (appsettingForTextSize >= Theme.fontSizeExtraLarge) {
            if (titleText.lineCount > 1)
                return Theme.itemSizeExtraLarge + 35
            else
                return Theme.itemSizeLarge - 2
        }
        if (appsettingForTextSize >= Theme.fontSizeLarge) {
            if (titleText.lineCount > 1)
                return Theme.itemSizeExtraLarge + 10
            else
                return Theme.itemSizeMedium - 5
        }
        if (appsettingForTextSize >= Theme.fontSizeMedium) {
            if (titleText.lineCount > 1)
                return Theme.itemSizeLarge + 15
            else
                return Theme.itemSizeSmall + 5
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
            return 2
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
            (index === coverProxy.currentQuestion - 1) ||
            (questionListView.currentIndex === index)) {
            color = Theme.highlightColor
        }
        return color
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
        text: questionsModel.getQuestionClosedAnsweredStatusAsText(index) + title
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
    Label {
        id: updaterLabelForFollowedQuestions
        visible: questionsModel.pageHeader === questionsModel.pageHeader_FOLLOWED_QUESTIONS &&
                 created === ""
        anchors.top: isTagsShown() ? tagsFlowColumn.bottom : titleText.bottom
        anchors.left: authorLabel.right
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.secondaryColor
        text: qsTr("(last updated by)")
    }

    StatsRow {
        id: staticticsRow
        createTimeVisible: questionsModel.pageHeader !== questionsModel.pageHeader_FOLLOWED_QUESTIONS ||
                           created !== ""
        parentWidth: background.width - authorLabel.width
        anchors.top: authorLabel.top
        anchors.left: authorLabel.right
    }

    Separator {
        width: parent.width
        visible: appSettings.question_list_show_separator_line_value
        anchors.top: staticticsRow.bottom
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
                onClicked: {
                    Clipboard.text = url
                    questionListView.currentIndex = index
                }
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

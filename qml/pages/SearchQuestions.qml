import QtQuick 2.1
import Sailfish.Silica 1.0
import "../components"

Dialog {
    id: searchFilterPage
    allowedOrientations: Orientation.All
    property string newSearchString: questionsModel.searchCriteria
    property string newSortingCriteria: questionsModel.sortingCriteriaQuestions
    property string newSortingOrder: questionsModel.sortingOrder

    ListModel {
        id: selectedTags
    }

    SilicaFlickable {
        id: mainFlic
        anchors.fill: parent
        contentHeight: content_column.height
        focus: true
        Keys.onEscapePressed: {
            pageStack.navigateBack()
        }
        Keys.onUpPressed: {
            scrollUp()
        }
        Keys.onDownPressed: {
            scrollDown()
        }
        function scrollDown () {
            contentY = Math.min (contentY + (height / 4), contentHeight - height);
        }
        function scrollUp () {
            contentY = Math.max (contentY - (height / 4), 0);
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset search")
                onClicked: {
                    resetSearch()
                }
            }
        }

        Column {
            id: content_column
            spacing: 2
            width: parent.width

            DialogHeader {
                id: header;
                title: qsTr("Search/Filter questions");
                acceptText: qsTr("Apply search");
            }

            SectionHeader {
                text: qsTr("Free text criteria")
            }
            SearchField {
                id: searchBox
                inputMethodHints: Qt.ImhNone
                placeholderText: qsTr("Search")
                width: parent.width
                text: questionsModel.searchCriteria // Show previous search if exists
                onTextChanged: {
                    newSearchString = searchBox.text
                }
                Keys.onReturnPressed: {
                    mainFlic.forceActiveFocus()
                }
            }

            SectionHeader {
                id: tagsLabel
                text: qsTr("Tags search criteria")
            }

            ItemFlowColumn {
                id: includedTags
                width: parent.width - 6 * Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter
                itemsArrayModel: getIncludedTags()
            }
            ItemFlowColumn {
                id: ignoredTags
                width: parent.width - 6 * Theme.paddingMedium
                dynTextStrikeOut: true
                anchors.horizontalCenter: parent.horizontalCenter
                itemsArrayModel: getIgnoredTags()
            }

            Button {
                id: tagButton
                text: qsTr("Add/Modify tags to search")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("TagSearch.qml"),
                                   {savedSearchTags: modelSearchTagsGlobal})
                    questionsModel.includeTagsChanged = false
                    questionsModel.ignoreTagsChanged = false
                }
            }

            SectionHeader {
                text: qsTr("Filters")
            }
            TextSwitch {
                id: closedSwitch
                checked: questionsModel.closedQuestionsFilter
                description: qsTr("List also closed questions")
                text: qsTr("Closed questions")
            }
            TextSwitch {
                id: answeredSwitch
                checked: questionsModel.answeredQuestionsFilter
                description: qsTr("List also questions having accepted answers")
                text: qsTr("Answered questions")
            }
            TextSwitch {
                id: unansweredSwitch
                checked: questionsModel.unansweredQuestionsFilter
                description: qsTr("List only questions having no answers yet. (Overrides 'Answered questions' selection)")
                text: qsTr("Unanswered questions")
            }

            SectionHeader {
                text: qsTr("Sorting")
            }
            ComboBox {
                id: sorting
                function set_value(value) {
                    var val = 0
                    if (value === questionsModel.sort_ACTIVITY)
                        val = 0
                    if (value === questionsModel.sort_AGE)
                        val = 1
                    if (value === questionsModel.sort_ANSWERS)
                        val = 2
                    if (value === questionsModel.sort_VOTES)
                        val = 3
                    sorting.currentIndex = val
                }
                label: qsTr("Sort by")
                menu: ContextMenu {
                    MenuItem {
                        id: sortmenuDefault
                        text: qsTr("Activity (Default)")
                        onClicked: {
                            newSortingCriteria = questionsModel.sort_ACTIVITY
                        }
                    }
                    MenuItem {
                       id: sortmenuAge
                       text: qsTr("Date")
                       onClicked: {
                           newSortingCriteria = questionsModel.sort_AGE
                       }
                    }
                    MenuItem {
                       id: sortmenuAnswers
                       text: qsTr("Answers")
                       onClicked: {
                           newSortingCriteria = questionsModel.sort_ANSWERS
                       }
                    }
                    MenuItem {
                       id: sortmenuVotes
                       text: qsTr("Votes")
                       onClicked: {
                           newSortingCriteria = questionsModel.sort_VOTES
                       }
                    }
                }
            }
            SectionHeader {
                text: qsTr("Sort order")
            }
            ComboBox {
                id: sortingOrder
                function set_value(value) {
                    var val = 0
                    if (value === questionsModel.sort_ORDER_DESC)
                        val = 0
                    if (value === questionsModel.sort_ORDER_ASC)
                        val = 1
                    sortingOrder.currentIndex = val
                }
                label: qsTr("Order by")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Descending (Default)")
                        onClicked: {
                            newSortingOrder = questionsModel.sort_ORDER_DESC
                        }
                    }
                    MenuItem {
                        text: qsTr("Ascending")
                        onClicked: {
                            newSortingOrder = questionsModel.sort_ORDER_ASC
                        }
                    }
                }
            }
            Label {
                id: noteLabel
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeTiny
                font.italic: true
                color: Theme.secondaryHighlightColor
                width: parent.width
                height: 100
                wrapMode: Text.Wrap
                text: qsTr("Note: Search criterias are global among all questions and persists untill changed from this page")
            }
        }        
    }

    onAccepted: {
        var reload = false
        if (searchStringsChanged())
            reload = true
        if (tagsChanged())
            reload = true
        if (filtersChanged())
            reload = true
        if (sortingChanged())
            reload = true
        if (reload)
            questionsModel.refresh()
    }

    Component.onCompleted: {
        sorting.set_value(questionsModel.sortingCriteriaQuestions)
        sortingOrder.set_value(questionsModel.sortingOrder)
    }

    function getIncludedTags() {
        var tagsArray = []
        for (var i = 0; i < modelSearchTagsGlobal.count; i++) {
            tagsArray[i] = modelSearchTagsGlobal.get(i).tag.toLowerCase()
        }
        return tagsArray
    }
    function getIgnoredTags() {
        var tagsArray = []
        for (var i = 0; i < ignoredSearchTagsGlobal.count; i++) {
            tagsArray[i] = ignoredSearchTagsGlobal.get(i).tag.toLowerCase()
        }
        return tagsArray
    }

    function searchStringsChanged() {
        var change = false
        if (newSearchString !== questionsModel.searchCriteria) {
            questionsModel.searchCriteria = newSearchString
            change = true
        }
        return change
    }
    function tagsChanged() {
        if (questionsModel.includeTagsChanged || questionsModel.ignoreTagsChanged)
            return true
        return false
    }
    function filtersChanged() {
        var change = false
        if (closedSwitch.checked !== questionsModel.closedQuestionsFilter) {
            questionsModel.closedQuestionsFilter = closedSwitch.checked
            change = true
        }
        if (answeredSwitch.checked !== questionsModel.answeredQuestionsFilter) {
            questionsModel.answeredQuestionsFilter = answeredSwitch.checked
            change = true
        }
        if (unansweredSwitch.checked !== questionsModel.unansweredQuestionsFilter) {
            questionsModel.unansweredQuestionsFilter = unansweredSwitch.checked
            change = true
        }
        return change
    }
    function sortingChanged() {
        var change = false
        if ((newSortingOrder !== questionsModel.sortingOrder) ||
            (newSortingCriteria !== questionsModel.sortingCriteriaQuestions )) {
            if (newSortingOrder !== questionsModel.sortingOrder) {
                questionsModel.sortingOrder = newSortingOrder
                change = true
            }
            if (newSortingCriteria !== questionsModel.sortingCriteriaQuestions) {
                questionsModel.sortingCriteriaQuestions = newSortingCriteria
                change = true
            }
        }
        return change
    }
    function resetSearch() {
        searchBox.text = ""
        newSearchString = ""

        questionsModel.includeTagsChanged = false
        questionsModel.ignoreTagsChanged = false
        if (modelSearchTagsGlobal.count > 0)
            questionsModel.includeTagsChanged = true
        if (ignoredSearchTagsGlobal.count > 0)
            questionsModel.ignoreTagsChanged = true
        modelSearchTagsGlobal.clear()
        ignoredSearchTagsGlobal.clear()

        closedSwitch.checked = questionsModel.closedQuestionsFilter_DEFAULT
        answeredSwitch.checked = questionsModel.answeredQuestionsFilter_DEFAULT
        unansweredSwitch.checked = questionsModel.unansweredQuestionsFilter_DEFAULT

        newSortingCriteria = questionsModel.sortingCriteriaQuestions_DEFAULT
        sorting.set_value(questionsModel.sortingCriteriaQuestions_DEFAULT)
        newSortingOrder = questionsModel.sortingOrder_DEFAULT
        sortingOrder.set_value(questionsModel.sortingOrder_DEFAULT)
    }
}

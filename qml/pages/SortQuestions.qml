import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: sortPage
    anchors.fill: parent
    property string newSortingCriteria: questionsModel.sortingCriteriaQuestions
    property string newSortingOrder: questionsModel.sortingOrder
    // orientation did not work ok for this page?
    //allowedOrientations: Orientation.All


    onStatusChanged: {
        // When leaving page change selections only if those are changed
        if (status === PageStatus.Deactivating) {
            if ((newSortingOrder !== questionsModel.sortingOrder) ||
                (newSortingCriteria !== questionsModel.sortingCriteriaQuestions )) {
                if (newSortingOrder !== questionsModel.sortingOrder) {
                    questionsModel.sortingOrder = newSortingOrder
                }
                if (newSortingCriteria !== questionsModel.sortingCriteriaQuestions) {
                    questionsModel.sortingCriteriaQuestions = newSortingCriteria
                }
                questionsModel.refresh()
            }
        }
    }

    SilicaFlickable
    {
        anchors.fill: parent
        Column {
            id: sortTypeColumn
            spacing: 1
            anchors.fill: parent
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            PageHeader {
                title: qsTr("Questions sorting criteria")
            }

            Rectangle{
                id: middleRectangle1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#333333" }
                    GradientStop { position: 1.0; color: "#777777" }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                height: 3
                width: parent.width-64
            }
            Label {
                width: parent.width-70
                font.pixelSize: Theme.fontSizeSmall
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("Select sorting type")
            }
            TextSwitch {
                id: activitySwitch
                automaticCheck: false
                checked: (questionsModel.sortingCriteriaQuestions === questionsModel.sort_ACTIVITY) ? true : false
                description: qsTr("Sort questions by most/least recently updated (=having activity)")
                text: qsTr("Activity (Default)")
                onClicked: {
                    newSortingCriteria = questionsModel.sort_ACTIVITY
                    toggleSortTypeSwitchesState(newSortingCriteria)
                }
            }
            TextSwitch {
                id: dateSwitch
                automaticCheck: false
                checked: (questionsModel.sortingCriteriaQuestions === questionsModel.sort_AGE) ? true : false
                description: qsTr("Sort questions by question creation date")
                text: qsTr("Date")
                onClicked: {
                    newSortingCriteria = questionsModel.sort_AGE
                    toggleSortTypeSwitchesState(newSortingCriteria)
                }

            }
            TextSwitch {
                id: answersSwitch
                automaticCheck: false
                checked: (questionsModel.sortingCriteriaQuestions === questionsModel.sort_ANSWERS) ? true : false
                description: qsTr("Sort questions by amount of answers")
                text: qsTr("Answers")
                onClicked: {
                    newSortingCriteria = questionsModel.sort_ANSWERS
                    toggleSortTypeSwitchesState(newSortingCriteria)
                }
            }
            TextSwitch {
                id: votesSwitch
                automaticCheck: false
                checked: (questionsModel.sortingCriteriaQuestions === questionsModel.sort_VOTES) ? true : false
                description: qsTr("Sort questions by amount of votes")
                text: qsTr("Votes")
                onClicked: {
                    newSortingCriteria = questionsModel.sort_VOTES
                    toggleSortTypeSwitchesState(newSortingCriteria)
                }
            }

            Rectangle{
                id: middleRectangle2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#333333" }
                    GradientStop { position: 1.0; color: "#777777" }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                height: 3
                width: parent.width-64
            }

            Label {
                width: parent.width-70
                font.pixelSize: Theme.fontSizeSmall
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("Select sort order")
            }
            TextSwitch {
                id: sortDescSwitch
                automaticCheck: false
                checked: (questionsModel.sortingOrder === questionsModel.sort_ORDER_DESC) ? true : false
                text: qsTr("Descending (Default)")
                onClicked: {
                    newSortingOrder = questionsModel.sort_ORDER_DESC
                    toggleSortOrderSwitchesState(newSortingOrder)
                }
            }
            TextSwitch {
                id: sortAscSwitch
                automaticCheck: false
                checked: (questionsModel.sortingOrder === questionsModel.sort_ORDER_ASC) ? true : false
                text: qsTr("Ascending")
                onClicked: {
                    newSortingOrder = questionsModel.sort_ORDER_ASC
                    toggleSortOrderSwitchesState(newSortingOrder)
                }
            }
            Rectangle{
                id: bottomRec
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#333333" }
                    GradientStop { position: 1.0; color: "#777777" }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                height: 3
                width: parent.width-64
            }

            Label {
                font.pixelSize: Theme.fontSizeTiny
                font.italic: true
                color: Theme.secondaryHighlightColor
                width: sortPage.width
                wrapMode: Text.Wrap
                text: qsTr("Note: Sorting is global among all questions and persists untill changed from this page")
            }
        }
    }

    function toggleSortTypeSwitchesState(criteria) {
        activitySwitch.checked = (criteria === questionsModel.sort_ACTIVITY) ? true : false
        dateSwitch.checked = (criteria === questionsModel.sort_AGE) ? true : false
        answersSwitch.checked = (criteria === questionsModel.sort_ANSWERS) ? true : false
        votesSwitch.checked = (criteria === questionsModel.sort_VOTES) ? true : false
    }
    function toggleSortOrderSwitchesState(order) {
        sortAscSwitch.checked = (order === questionsModel.sort_ORDER_ASC) ? true : false
        sortDescSwitch.checked = (order === questionsModel.sort_ORDER_DESC) ? true : false
    }
}

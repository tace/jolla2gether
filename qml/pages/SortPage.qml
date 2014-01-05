import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: sortPage
    anchors.fill: parent

    SilicaFlickable
    {
        anchors.fill: parent
        Column {
            id: sortTypeColumn
            //spacing: 1
            anchors.fill: parent
            //anchors.leftMargin: Theme.paddingMedium
            //anchors.rightMargin: Theme.paddingMedium
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
                checked: (sortingCriteria == sort_ACTIVITY) ? true : false
                description: "Sort questions by most/least recently updated (=having activity)"
                text: qsTr("Activity (Default)")
                onClicked: {
                    sortingCriteria = sort_ACTIVITY
                    toggleSortTypeSwitchesState()
                }
            }
            TextSwitch {
                id: dateSwitch
                automaticCheck: false
                checked: (sortingCriteria == sort_AGE) ? true : false
                description: "Sort questions by question creation date"
                text: qsTr("Date")
                onClicked: {
                    sortingCriteria = sort_AGE
                    toggleSortTypeSwitchesState()
                }

            }
            TextSwitch {
                id: answersSwitch
                automaticCheck: false
                checked: (sortingCriteria == sort_ANSWERS) ? true : false
                description: "Sort questions by amount of answers"
                text: qsTr("Answers")
                onClicked: {
                    sortingCriteria = sort_ANSWERS
                    toggleSortTypeSwitchesState()
                }
            }
            TextSwitch {
                id: votesSwitch
                automaticCheck: false
                checked: (sortingCriteria == sort_VOTES) ? true : false
                description: "Sort questions by amount of votes"
                text: qsTr("Votes")
                onClicked: {
                    sortingCriteria = sort_VOTES
                    toggleSortTypeSwitchesState()
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
                checked: (sortingOrder == sort_ORDER_DESC) ? true : false
                text: qsTr("Descending (Default)")
                onClicked: {
                    sortingOrder = sort_ORDER_DESC
                    toggleSortOrderSwitchesState()
                }
            }
            TextSwitch {
                id: sortAscSwitch
                automaticCheck: false
                checked: (sortingOrder == sort_ORDER_ASC) ? true : false
                text: qsTr("Ascending")
                onClicked: {
                    sortingOrder = sort_ORDER_ASC
                    toggleSortOrderSwitchesState()
                }
            }

            Label {
                font.pixelSize: Theme.fontSizeExtraSmall
                color: "red"
                width: sortPage.width
                wrapMode: Text.Wrap
                text: qsTr("Note: Sorting is global among all questions and selected sorting persists untill it's changed from this page")
            }
        }
    }

    function toggleSortTypeSwitchesState() {
        activitySwitch.checked = (sortingCriteria == sort_ACTIVITY) ? true : false
        dateSwitch.checked = (sortingCriteria == sort_AGE) ? true : false
        answersSwitch.checked = (sortingCriteria == sort_ANSWERS) ? true : false
        votesSwitch.checked = (sortingCriteria == sort_VOTES) ? true : false
        refresh() // reload model to first page
    }
    function toggleSortOrderSwitchesState() {
        sortAscSwitch.checked = (sortingOrder == sort_ORDER_ASC) ? true : false
        sortDescSwitch.checked = (sortingOrder == sort_ORDER_DESC) ? true : false
        refresh() // reload model to first page
    }
}

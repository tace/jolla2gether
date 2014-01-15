import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: sortPage
    anchors.fill: parent
    property string newSortingCriteria: sortingCriteria
    property string newSortingOrder: sortingOrder
    // orientation did not work ok for this page?
    //allowedOrientations: Orientation.All


    onStatusChanged: {
        // When leaving page change selections only if those are changed
        if (status === PageStatus.Deactivating) {
            if ((newSortingOrder !== sortingOrder) || (newSortingCriteria !== sortingCriteria )) {
                if (newSortingOrder !== sortingOrder) {
                    sortingOrder = newSortingOrder
                }
                if (newSortingCriteria !== sortingCriteria) {
                    sortingCriteria = newSortingCriteria
                }
                refresh()
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
                checked: (sortingCriteria == sort_ACTIVITY) ? true : false
                description: qsTr("Sort questions by most/least recently updated (=having activity)")
                text: qsTr("Activity (Default)")
                onClicked: {
                    newSortingCriteria = sort_ACTIVITY
                    toggleSortTypeSwitchesState(newSortingCriteria)
                }
            }
            TextSwitch {
                id: dateSwitch
                automaticCheck: false
                checked: (sortingCriteria == sort_AGE) ? true : false
                description: qsTr("Sort questions by question creation date")
                text: qsTr("Date")
                onClicked: {
                    newSortingCriteria = sort_AGE
                    toggleSortTypeSwitchesState(newSortingCriteria)
                }

            }
            TextSwitch {
                id: answersSwitch
                automaticCheck: false
                checked: (sortingCriteria == sort_ANSWERS) ? true : false
                description: qsTr("Sort questions by amount of answers")
                text: qsTr("Answers")
                onClicked: {
                    newSortingCriteria = sort_ANSWERS
                    toggleSortTypeSwitchesState(newSortingCriteria)
                }
            }
            TextSwitch {
                id: votesSwitch
                automaticCheck: false
                checked: (sortingCriteria == sort_VOTES) ? true : false
                description: qsTr("Sort questions by amount of votes")
                text: qsTr("Votes")
                onClicked: {
                    newSortingCriteria = sort_VOTES
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
                checked: (sortingOrder == sort_ORDER_DESC) ? true : false
                text: qsTr("Descending (Default)")
                onClicked: {
                    newSortingOrder = sort_ORDER_DESC
                    toggleSortOrderSwitchesState(newSortingOrder)
                }
            }
            TextSwitch {
                id: sortAscSwitch
                automaticCheck: false
                checked: (sortingOrder == sort_ORDER_ASC) ? true : false
                text: qsTr("Ascending")
                onClicked: {
                    newSortingOrder = sort_ORDER_ASC
                    toggleSortOrderSwitchesState(newSortingOrder)
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

    function toggleSortTypeSwitchesState(criteria) {
        activitySwitch.checked = (criteria === sort_ACTIVITY) ? true : false
        dateSwitch.checked = (criteria === sort_AGE) ? true : false
        answersSwitch.checked = (criteria === sort_ANSWERS) ? true : false
        votesSwitch.checked = (criteria === sort_VOTES) ? true : false
    }
    function toggleSortOrderSwitchesState(order) {
        sortAscSwitch.checked = (order === sort_ORDER_ASC) ? true : false
        sortDescSwitch.checked = (order === sort_ORDER_DESC) ? true : false
    }
}

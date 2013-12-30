import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    anchors.fill: parent
    id: sortPage
    property string sort_ACTIVITY:      "activity"
    property string sort_AGE:           "age"
    property string sort_ANSWERS:       "answers"
    property string sort_VOTES:         "votes"
    property string sort_ORDER_ASC:     "asc"
    property string sort_ORDER_DESC:    "desc"

    Column
    {
        id: sortTypeColumn
        spacing: 1
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        PageHeader {
            title: "Select sorting criterias"
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
            text: "Select sorting type"
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        TextSwitch {
            id: activitySwitch
            text: "Activity (Default)"
            automaticCheck: false
            checked: (sortingCriteria == sort_ACTIVITY) ? true : false
            description: "Sort questions by most/least recently updated (=having activity)"
            onClicked: {
                sortingCriteria = sort_ACTIVITY
                toggleSortTypeSwitchesState()
            }
        }
        TextSwitch {
            id: dateSwitch
            text: "Date"
            automaticCheck: false
            checked: (sortingCriteria == sort_AGE) ? true : false
            description: "Sort questions by question creation date"
            onClicked: {
                sortingCriteria = sort_AGE
                toggleSortTypeSwitchesState()
            }

        }
        TextSwitch {
            id: answersSwitch
            text: "Answers"
            automaticCheck: false
            checked: (sortingCriteria == sort_ANSWERS) ? true : false
            description: "Sort questions by amount of answers"
            onClicked: {
                sortingCriteria = sort_ANSWERS
                toggleSortTypeSwitchesState()
            }
        }
        TextSwitch {
            id: votesSwitch
            text: "Votes"
            automaticCheck: false
            checked: (sortingCriteria == sort_VOTES) ? true : false
            description: "Sort questions by amount of votes"
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
            text: "Select sort order"
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        TextSwitch {
            id: sortAscSwitch
            text: "Ascending"
            automaticCheck: false
            checked: (sortingOrder == sort_ORDER_ASC) ? true : false
            onClicked: {
                sortingOrder = sort_ORDER_ASC
                toggleSortOrderSwitchesState()
            }
        }
        TextSwitch {
            id: sortDescSwitch
            text: "Descending (Default)"
            automaticCheck: false
            checked: (sortingOrder == sort_ORDER_DESC) ? true : false
            onClicked: {
                sortingOrder = sort_ORDER_DESC
                toggleSortOrderSwitchesState()
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

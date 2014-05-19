import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: sortPage
    allowedOrientations: Orientation.All
    property string newSortingCriteria: usersModel.sortingCriteriaUsers

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: sortTypeColumn.height

        Column {
            id: sortTypeColumn
            spacing: 2
            width: parent.width

            DialogHeader {
                id: header;
                title: qsTr("Users sorting criteria");
                acceptText: qsTr("Apply sorting");
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
                id: karmaSwitch
                automaticCheck: false
                checked: (usersModel.sortingCriteriaUsers === usersModel.sort_REPUTATION) ? true : false
                description: qsTr("Sort users by highest reputation")
                text: qsTr("Karma (Default)")
                onClicked: {
                    newSortingCriteria = usersModel.sort_REPUTATION
                    toggleSortTypeSwitchesState(newSortingCriteria)
                }
            }
            TextSwitch {
                id: recentSwitch
                automaticCheck: false
                checked: (usersModel.sortingCriteriaUsers === usersModel.sort_RECENT) ? true : false
                description: qsTr("See users who joined most recently")
                text: qsTr("Recent")
                onClicked: {
                    newSortingCriteria = usersModel.sort_RECENT
                    toggleSortTypeSwitchesState(newSortingCriteria)
                }
            }
            TextSwitch {
                id: oldestSwitch
                automaticCheck: false
                checked: (usersModel.sortingCriteriaUsers === usersModel.sort_OLDEST) ? true : false
                description: qsTr("See users who joined the site first")
                text: qsTr("Oldest")
                onClicked: {
                    newSortingCriteria = usersModel.sort_OLDEST
                    toggleSortTypeSwitchesState(newSortingCriteria)
                }
            }
            TextSwitch {
                id: nameSwitch
                automaticCheck: false
                checked: (usersModel.sortingCriteriaUsers === usersModel.sort_USERNAME) ? true : false
                description: qsTr("See users sorted by username")
                text: qsTr("Username")
                onClicked: {
                    newSortingCriteria = usersModel.sort_USERNAME
                    toggleSortTypeSwitchesState(newSortingCriteria)
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
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeTiny
                font.italic: true
                color: Theme.secondaryHighlightColor
                width: parent.width - 70
                height: 250
                wrapMode: Text.Wrap
                text: qsTr("Note: Sorting is global among all users and persists untill changed from this page")
            }
        }
    }

    onAccepted: {
        if (newSortingCriteria !== usersModel.sortingCriteriaUsers) {
            usersModel.sortingCriteriaUsers = newSortingCriteria
            usersModel.refresh()
        }
    }

    function toggleSortTypeSwitchesState(criteria) {
        karmaSwitch.checked = (criteria === usersModel.sort_REPUTATION) ? true : false
        recentSwitch.checked = (criteria === usersModel.sort_RECENT) ? true : false
        oldestSwitch.checked = (criteria === usersModel.sort_OLDEST) ? true : false
        nameSwitch.checked = (criteria === usersModel.sort_USERNAME) ? true : false
    }
}

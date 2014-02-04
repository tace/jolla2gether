import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: sortPage
    anchors.fill: parent
    property string newSortingCriteria: usersModel.sortingCriteriaUsers
    // orientation did not work ok for this page?
    //allowedOrientations: Orientation.All


    onStatusChanged: {
        // When leaving page change selections only if those are changed
        if (status === PageStatus.Deactivating) {
            if (newSortingCriteria !== usersModel.sortingCriteriaUsers) {
                usersModel.sortingCriteriaUsers = newSortingCriteria
                usersModel.refresh()
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
                title: qsTr("Users sorting criteria")
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
                font.pixelSize: Theme.fontSizeTiny
                font.italic: true
                color: Theme.secondaryHighlightColor
                width: sortPage.width
                wrapMode: Text.Wrap
                text: qsTr("Note: Sorting is global among all users and persists untill changed from this page")
            }
        }
    }

    function toggleSortTypeSwitchesState(criteria) {
        karmaSwitch.checked = (criteria === usersModel.sort_REPUTATION) ? true : false
        recentSwitch.checked = (criteria === usersModel.sort_RECENT) ? true : false
        oldestSwitch.checked = (criteria === usersModel.sort_OLDEST) ? true : false
        nameSwitch.checked = (criteria === usersModel.sort_USERNAME) ? true : false
    }
}

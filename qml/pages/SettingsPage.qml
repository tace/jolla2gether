import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    id: settingsPage
    allowedOrientations: Orientation.All
    property string newTitleSpaceValue: appSettings.qUESTION_LIST_TITLE_SPACE_VALUE
    property bool newSwipeBackFromWebviewValue: appSettings.webview_swipe_back_enabled_value

    SilicaFlickable {
        id: mainFlic
        anchors.fill: parent
        contentHeight: content_column.height

        Column {
            id: content_column
            spacing: 2
            width: parent.width

            PageHeader {
                title: qsTr("Jolla2gether settings")
            }

            SectionHeader {
                text: qsTr("Questions list presentation")
            }

            ComboBox {
                id: titleSpace
                function set_value(value) {
                    var val = 0
                    if (value === appSettings.qUESTION_LIST_TITLE_SPACE_VALUE_ONE_LINE)
                        val = 0
                    if (value === appSettings.qUESTION_LIST_TITLE_SPACE_VALUE_2_LINES)
                        val = 1
                    titleSpace.currentIndex = val
                }
                label: qsTr("Space used for question title")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("One line (Default)")
                        onClicked: {
                            newTitleSpaceValue = appSettings.qUESTION_LIST_TITLE_SPACE_VALUE_ONE_LINE
                        }
                    }
                    MenuItem {
                       text: qsTr("2 lines")
                       onClicked: {
                           newTitleSpaceValue = appSettings.qUESTION_LIST_TITLE_SPACE_VALUE_2_LINES
                       }
                    }
                }
            }
            SectionHeader {
                text: qsTr("Webview")
            }

            ComboBox {
                id: swipeBackFromWebview
                function set_value(value) {
                    var val = 0
                    if (!value)
                        val = 0
                    if (value)
                        val = 1
                    swipeBackFromWebview.currentIndex = val
                }
                label: qsTr("Swipe back from to questions list")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Disabled (Default)")
                        onClicked: {
                            newSwipeBackFromWebviewValue = false
                        }
                    }
                    MenuItem {
                       text: qsTr("Enabled")
                       onClicked: {
                           newSwipeBackFromWebviewValue = true
                       }
                    }
                }
            }
        } // column
    }

    onStatusChanged: {
        // When leaving page
        if (status === PageStatus.Deactivating) {
            if (newTitleSpaceValue !== appSettings.qUESTION_LIST_TITLE_SPACE_VALUE) {
                appSettings.qUESTION_LIST_TITLE_SPACE_VALUE = newTitleSpaceValue
            }
            if (newSwipeBackFromWebviewValue !== appSettings.webview_swipe_back_enabled_value) {
                appSettings.webview_swipe_back_enabled_value = newSwipeBackFromWebviewValue
            }
        }
    }
    Component.onCompleted: {
        titleSpace.set_value(appSettings.qUESTION_LIST_TITLE_SPACE_VALUE)
        swipeBackFromWebview.set_value(appSettings.webview_swipe_back_enabled_value)
    }

}

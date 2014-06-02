import QtQuick 2.1
import Sailfish.Silica 1.0

Dialog {
    id: settingsPage
    allowedOrientations: Orientation.All
    property string newQuestionListTitleSpaceValue: appSettings.qUESTION_LIST_TITLE_SPACE_VALUE
    property bool newQuestionResetSearchOnListingUserQuestionsValue: appSettings.question_reset_search_on_listing_user_questions_value
    property bool newWebviewSwipeBackEnabledValue: appSettings.webview_swipe_back_enabled_value

    SilicaFlickable {
        id: mainFlic
        anchors.fill: parent
        contentHeight: content_column.height

        Column {
            id: content_column
            spacing: 2
            width: parent.width

            DialogHeader {
                id: header;
                title: qsTr("Settings");
                acceptText: qsTr("Save");
            }

            SectionHeader {
                text: qsTr("Question list presentation")
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
                            newQuestionListTitleSpaceValue = appSettings.qUESTION_LIST_TITLE_SPACE_VALUE_ONE_LINE
                        }
                    }
                    MenuItem {
                       text: qsTr("2 lines")
                       onClicked: {
                           newQuestionListTitleSpaceValue = appSettings.qUESTION_LIST_TITLE_SPACE_VALUE_2_LINES
                       }
                    }
                }
            }

            SectionHeader {
                text: qsTr("Question search for user's questions")
            }
            Label {
                id: notesubSearchReset
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeTiny
                font.italic: true
                color: Theme.secondaryHighlightColor
                width: parent.width
                height: 150
                wrapMode: Text.Wrap
                text: qsTr("Questions of given user can be listed in Users page or Questions page by long pressing list item. With this setting, existing search criteria (if set) can be applied also to users's all questions or resetted. Note that on users's all questions page you can freely change/reset search criteria and it do not affect to original search criteria i.e. when returning back to main questions list the original search criteria is returned.")
            }
            ComboBox {
                id: subSearchReset
                function set_value(value) {
                    var val = 0
                    if (!value)
                        val = 0
                    if (value)
                        val = 1
                    subSearchReset.currentIndex = val
                }
                label: qsTr("Keep/Reset existing search criteria")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Keep search criteria (Default)")
                        onClicked: {
                            newQuestionResetSearchOnListingUserQuestionsValue = false
                        }
                    }
                    MenuItem {
                       text: qsTr("Reset search criteria")
                       onClicked: {
                           newQuestionResetSearchOnListingUserQuestionsValue = true
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
                label: qsTr("Swipe back from webview")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Disabled (Default)")
                        onClicked: {
                            newWebviewSwipeBackEnabledValue = false
                        }
                    }
                    MenuItem {
                       text: qsTr("Enabled")
                       onClicked: {
                           newWebviewSwipeBackEnabledValue = true
                       }
                    }
                }
            }
        } // column
    }
    onAccepted: {
        appSettings.qUESTION_LIST_TITLE_SPACE_VALUE = newQuestionListTitleSpaceValue
        appSettings.question_reset_search_on_listing_user_questions_value = newQuestionResetSearchOnListingUserQuestionsValue
        appSettings.webview_swipe_back_enabled_value = newWebviewSwipeBackEnabledValue
    }
    Component.onCompleted: {
        titleSpace.set_value(appSettings.qUESTION_LIST_TITLE_SPACE_VALUE)
        swipeBackFromWebview.set_value(appSettings.webview_swipe_back_enabled_value)
        subSearchReset.set_value(appSettings.question_reset_search_on_listing_user_questions_value)
    }

}

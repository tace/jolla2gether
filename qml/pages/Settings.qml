import QtQuick 2.0

QtObject {
    property string qUESTION_LIST_TITLE_SPACE: "question_title_space"
    property string qUESTION_LIST_TITLE_SPACE_VALUE_ONE_LINE: "one_line"
    property string qUESTION_LIST_TITLE_SPACE_VALUE_2_LINES: "2_lines"
    property string qUESTION_LIST_TITLE_SPACE_VALUE: Settings.value(qUESTION_LIST_TITLE_SPACE, qUESTION_LIST_TITLE_SPACE_VALUE_ONE_LINE)

    property string webview_swipe_back_enabled: "webview_swipe_back_enabled"
    property bool webview_swipe_back_enabled_value: Settings.value(webview_swipe_back_enabled, false) === "true"

    onQUESTION_LIST_TITLE_SPACE_VALUEChanged: Settings.setValue(qUESTION_LIST_TITLE_SPACE, qUESTION_LIST_TITLE_SPACE_VALUE)
    onWebview_swipe_back_enabled_valueChanged: Settings.setValue(webview_swipe_back_enabled, webview_swipe_back_enabled_value)
}

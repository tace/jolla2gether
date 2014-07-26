import QtQuick 2.0
import Sailfish.Silica 1.0

QtObject {
    property string qUESTION_LIST_TITLE_SPACE: "question_title_space"
    property string qUESTION_LIST_TITLE_SPACE_VALUE_ONE_LINE: "one_line"
    property string qUESTION_LIST_TITLE_SPACE_VALUE_2_LINES: "2_lines"
    property string qUESTION_LIST_TITLE_SPACE_VALUE: Settings.value(qUESTION_LIST_TITLE_SPACE, qUESTION_LIST_TITLE_SPACE_VALUE_ONE_LINE)

    property string question_reset_search_on_listing_user_questions: "question_reset_search_on_listing_user_questions"
    property bool question_reset_search_on_listing_user_questions_value: Settings.value(question_reset_search_on_listing_user_questions, false) === "true"

    property string webview_swipe_back_enabled: "webview_swipe_back_enabled"
    property bool webview_swipe_back_enabled_value: Settings.value(webview_swipe_back_enabled, false) === "true"

    property string question_list_title_font_size: "question_list_title_font_size"
    property int question_list_title_font_size_value: Settings.value(question_list_title_font_size, Theme.fontSizeSmall)

    property string question_view_page_font_size: "question_view_page_font_size"
    property int question_view_page_font_size_value: Settings.value(question_view_page_font_size, Theme.fontSizeSmall)

    property string question_view_page_answers_and_comments_font_size: "question_view_page_answers_and_comments_font_size"
    property int question_view_page_answers_and_comments_font_size_value: Settings.value(question_view_page_answers_and_comments_font_size, Theme.fontSizeTiny)

    //
    // on value change callbacks
    //
    onQUESTION_LIST_TITLE_SPACE_VALUEChanged: Settings.setValue(qUESTION_LIST_TITLE_SPACE, qUESTION_LIST_TITLE_SPACE_VALUE)
    onQuestion_reset_search_on_listing_user_questions_valueChanged: Settings.setValue(question_reset_search_on_listing_user_questions, question_reset_search_on_listing_user_questions_value)
    onWebview_swipe_back_enabled_valueChanged: Settings.setValue(webview_swipe_back_enabled, webview_swipe_back_enabled_value)
    onQuestion_list_title_font_size_valueChanged: Settings.setValue(question_list_title_font_size, question_list_title_font_size_value)
    onQuestion_view_page_answers_and_comments_font_size_valueChanged: Settings.setValue(question_view_page_answers_and_comments_font_size, question_view_page_answers_and_comments_font_size_value)
}

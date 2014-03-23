import QtQuick 2.0
import "../../js/askbot.js" as Askbot

ListModel {
    id: listModel

    // Questions counters
    property int pagesCount: 0;
    property int currentPageNum: 1;
    property int questionsCount: 0;

    // Filters
    property bool closedQuestionsFilter_DEFAULT: true
    property bool closedQuestionsFilter: closedQuestionsFilter_DEFAULT
    property bool answeredQuestionsFilter_DEFAULT: true
    property bool answeredQuestionsFilter: answeredQuestionsFilter_DEFAULT
    property bool unansweredQuestionsFilter_DEFAULT: false
    property bool unansweredQuestionsFilter: unansweredQuestionsFilter_DEFAULT

    // Sorting questions
    property string sort_ACTIVITY:      "activity"
    property string sort_AGE:           "age"
    property string sort_ANSWERS:       "answers"
    property string sort_VOTES:         "votes"
    property string sort_ORDER_ASC:     "asc"
    property string sort_ORDER_DESC:    "desc"

    property string sortingCriteriaQuestions_DEFAULT:       sort_ACTIVITY;
    property string sortingCriteriaQuestions:               sortingCriteriaQuestions_DEFAULT;
    property string sortingOrder_DEFAULT:                   sort_ORDER_DESC;
    property string sortingOrder:                           sortingOrder_DEFAULT;

    // Search
    property string searchCriteria: ""
    property bool includeTagsChanged: false
    property bool ignoreTagsChanged: false

    function refresh(page, onLoadedCallback)
    {
        clear()
        get_questions(page, onLoadedCallback) // goes to first page if page not given
    }
    function get_nextPageQuestions(params)
    {
        var askedPage = 0
        if (currentPageNum < pagesCount) {
            askedPage = currentPageNum + 1
        }
        else {
            askedPage = pagesCount
        }
        if (currentPageNum === pagesCount) {
            console.log("no more pages to load!")
        }
        else
            get_questions(askedPage, params)
    }
    function get_questions(page, onLoadedCallback)
    {
        Askbot.get_questions(listModel, page, onLoadedCallback)
    }

}

import QtQuick 2.0
import "../../js/askbot.js" as Askbot

ListModel {
    id: listModel

    property bool loaded: false
    // Questions counters
    property int pagesCount: 0;
    property int currentPageNum: 1;
    property int questionsCount: 0;

    // Filters
    property bool closedQuestionsFilter: true
    property bool answeredQuestionsFilter: true
    property bool unansweredQuestionsFilter: false

    // Sorting questions
    property string sort_ACTIVITY:      "activity"
    property string sort_AGE:           "age"
    property string sort_ANSWERS:       "answers"
    property string sort_VOTES:         "votes"
    property string sort_ORDER_ASC:     "asc"
    property string sort_ORDER_DESC:    "desc"

    property string sortingCriteriaQuestions:       sort_ACTIVITY;
    property string sortingOrder:                   sort_ORDER_DESC;

    // Search
    property string searchCriteria: ""

    function refresh(page)
    {
        clear()
        get_questions(page) // goes to first page if page not given
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
        loaded = true
    }

}

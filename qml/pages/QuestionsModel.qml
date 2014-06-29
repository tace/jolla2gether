import QtQuick 2.0
import "../../js/askbot.js" as Askbot
import "../../js/custom.js" as Custom

ListModel {
    id: listModel

    // Questions counters
    property int pagesCount: 0;
    property int currentPageNum: 1;
    property int questionsCount: 0;
    property int listViewCurrentIndex: 0; // To handle list when back to all questions from user's questions

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
    property string ownUserIdValue: ""
    property string userIdSearchCriteria: ""
    property bool userQuestionsAsked: false
    property bool includeTagsChanged: false
    property bool ignoreTagsChanged: false

    // Login
    property int loginRetryCount: 0
    property int loginRetryCountMaximum: 3

    // Header
    property string pageHeader_ALL_QUESTIONS: "All questions"  // Default
    property string pageHeader_MY_QUESTIONS:  "My questions"
    property string pageHeader: pageHeader_ALL_QUESTIONS

    // Toggle for all/My questions
    property bool myQuestionsToggle: false

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

    function pushWebviewWithCustomScript(attached, props) {
        var closure = function(result) {
            questionsModel.ownUserIdValue = result
        };
        var properties = {}
        if (((questionsModel.ownUserIdValue === "" ||
            questionsModel.ownUserIdValue === "signin") &&
            loginRetryCount < loginRetryCountMaximum) ||
            !attached) {
            var custom_scrip_props = {customJavaScriptToExecute : Custom.get_userId_script(),
                                      customJavaScriptResultHandler: Custom.get_userId_script_result_handler(closure)}
            properties = merge(custom_scrip_props, props)
            loginRetryCount = loginRetryCount + 1
        }
        else {
            properties = props
        }

        if (attached) {
            pageStack.pushAttached(Qt.resolvedUrl("WebView.qml"), properties)
        }
        else {
            pageStack.push(Qt.resolvedUrl("WebView.qml"), properties)
        }
    }

    function merge() {
        var obj = {},
            i = 0,
            il = arguments.length,
            key;
        for (; i < il; i++) {
            for (key in arguments[i]) {
                if (arguments[i].hasOwnProperty(key)) {
                    obj[key] = arguments[i][key];
                }
            }
        }
        return obj;
    }

    function setUserIdSearchCriteria(userId) {
        console.log("Userid: "+userId)
        if (userId !== "" && userId !== "signin") {
            questionsModel.userIdSearchCriteria = userId
            return true
        }
        return false
    }
    function isSearchCriteriaActive() {
        if (questionsModel.searchCriteria !== "" ||
            isFilterCriteriasActive() ||
            modelSearchTagsGlobal.count > 0 ||
            ignoredSearchTagsGlobal.count > 0)
            return true
        return false
    }
    function isFilterCriteriasActive() {
        if (questionsModel.closedQuestionsFilter !== questionsModel.closedQuestionsFilter_DEFAULT ||
            questionsModel.answeredQuestionsFilter !== questionsModel.answeredQuestionsFilter_DEFAULT ||
            questionsModel.unansweredQuestionsFilter !== questionsModel.unansweredQuestionsFilter_DEFAULT)
            return true
        return false
    }
    function resetUserIdSearchCriteria() {
        questionsModel.userIdSearchCriteria = ""
        questionsModel.pageHeader = questionsModel.pageHeader_ALL_QUESTIONS
    }
    function resetSearchCriteria() {
        questionsModel.searchCriteria = ""
        questionsModel.closedQuestionsFilter = questionsModel.closedQuestionsFilter_DEFAULT
        questionsModel.answeredQuestionsFilter = questionsModel.answeredQuestionsFilter_DEFAULT
        questionsModel.unansweredQuestionsFilter = questionsModel.unansweredQuestionsFilter_DEFAULT
        questionsModel.sortingCriteriaQuestions = questionsModel.sortingCriteriaQuestions_DEFAULT
        questionsModel.sortingOrder = questionsModel.sortingOrder_DEFAULT
        modelSearchTagsGlobal.clear()
        ignoredSearchTagsGlobal.clear()
    }
    function cacheModel() {
        questionsModel.userQuestionsAsked = true
        copyModel(questionsModel, questionsModelCache)

        // Copy also tags models here
        copyListModel(modelSearchTagsGlobal, modelSearchTagsGlobalCache)
        copyListModel(ignoredSearchTagsGlobal, ignoredSearchTagsGlobalCache)
    }
    function restoreModel() {
        copyModel(questionsModelCache, questionsModel)
        questionsModel.userQuestionsAsked = false

        // Restore tags models
        copyListModel(modelSearchTagsGlobalCache, modelSearchTagsGlobal)
        copyListModel(ignoredSearchTagsGlobalCache, ignoredSearchTagsGlobal)
    }
    function copyListModel(o, t) {
        t.clear()
        for (var i = 0; i < o.count; i++) {
            t.append(o.get(i))
        }
    }
    function copyModel(p, c) {
        copyListModel(p, c)

        c.listViewCurrentIndex = p.listViewCurrentIndex
        c.pagesCount = p.pagesCount;
        c.currentPageNum = p.currentPageNum;
        c.questionsCount = p.questionsCount;

        c.closedQuestionsFilter = p.closedQuestionsFilter
        c.answeredQuestionsFilter = p.answeredQuestionsFilter
        c.unansweredQuestionsFilter = p.unansweredQuestionsFilter

        c.sortingCriteriaQuestions = p.sortingCriteriaQuestions
        c.sortingOrder = p.sortingOrder

        c.searchCriteria = p.searchCriteria
        c.ownUserIdValue = p.ownUserIdValue
        c.userIdSearchCriteria = p.userIdSearchCriteria
        c.includeTagsChanged = p.includeTagsChanged
        c.ignoreTagsChanged = p.ignoreTagsChanged

        c.loginRetryCount = p.loginRetryCount

        c.pageHeader = p.pageHeader

        c.myQuestionsToggle = p.myQuestionsToggle
    }
    function wiki2Html(text) {
        return Askbot.wiki2Html(text)
    }
    function rssPubDate2Seconds(rssPubDate) {
        var date = new Date(rssPubDate);
        return date.getTime() / 1000; // seconds since midnight, 1 Jan 1970
    }
    function rssPubdate2ElapsedTimeString(rssPubDate) {
        var seconds = rssPubDate2Seconds(rssPubDate)
        return Askbot.getTimeDurationAsString(seconds).trim()
    }
}

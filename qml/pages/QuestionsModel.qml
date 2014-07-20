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
        var callbacksList = []
        var properties = {}
        if (((questionsModel.ownUserIdValue === "" ||
              questionsModel.ownUserIdValue === "signin") &&
             loginRetryCount < loginRetryCountMaximum) ||
                !attached) {
            callbacksList.push(getUserIdFromWebViewCallback())
            loginRetryCount = loginRetryCount + 1
        }
        if (pageStack.currentPage.objectName === "QuestionViewPage") {
            callbacksList.push(getVotingDataFromWebViewCallback(getQuestionId(),
                                                                pageStack.currentPage.votingResultsCallback))
        }
        if (callbacksList.length > 0) {
            properties = merge(props, {callbacks: callbacksList})
        }
        else
            properties = props

        //printProps(properties)
        if (attached) {
            return pageStack.pushAttached(Qt.resolvedUrl("WebView.qml"), properties)
        }
        else {
            return pageStack.push(Qt.resolvedUrl("WebView.qml"), properties)
        }
    }

    function getQuestionId() {
        return questionsModel.get(questionsModel.listViewCurrentIndex).id
    }

    // Custom javascript to executein webview. Picks userId field from together.jolla.com
    // site.
    // First href in the userToolsNav element should return either
    //     "/account/signin/?next=/"    (not logged in)
    // or
    //     "/users/497/tace/"           (logged in)
    //
    // So this function returns userId number (e.g. 497) or "signin" string.
    function getUserIdFromWebViewCallback() {
        return function(webview) {
            var scriptToRun = "(function() { \
            var userElem = document.getElementById('userToolsNav'); \
            var firstHref = userElem.getElementsByTagName('a')[0].getAttribute('href'); \
            return firstHref.split('/')[2]; \
            })()"
            var handleResult = function(result) {
                questionsModel.ownUserIdValue = result
                console.log( "Got userId from webview: " + result );
            }
            webview.evaluateJavaScriptOnWebPage(scriptToRun, handleResult)
        }
    }

    function getVotingDataFromWebViewCallback(questionId, votingResultsCallback) {
        return function(webview) {
            var scriptToRun = "(function() { \
                        var upvoteElem = document.getElementById('question-img-upvote-" + questionId + "'); \
                        var upvoteOn = upvoteElem.getAttribute('class').split('question-img-upvote post-vote upvote')[1]; \
                        var downvoteElem = document.getElementById('question-img-downvote-" + questionId + "'); \
                        var downvoteOn = downvoteElem.getAttribute('class').split('question-img-downvote post-vote downvote')[1]; \
                        return upvoteOn + ',' + downvoteOn \
                        })()"
            var handleVoteResult = function(result) {
                var upDownVotes = result.split(',')
                var upVoteOn = false
                var downVoteOn = false
                if (upDownVotes[0].trim() !== '')
                    upVoteOn = true
                if (upDownVotes[1].trim() !== '')
                    downVoteOn = true
                console.log("Got votes status from webview. upVote: " + upVoteOn + ", downVote: " + downVoteOn)
                votingResultsCallback(upVoteOn, downVoteOn)
            }
            webview.evaluateJavaScriptOnWebPage(scriptToRun, handleVoteResult)
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
    function printProps() {
        var i = 0,
                il = arguments.length,
                key;
        console.log("properties:")
        for (; i < il; i++) {
            for (key in arguments[i]) {
                console.log(key + ": " + arguments[i][key])
            }
        }
    }
    function getProp() {
        var name = arguments[0]
        var j=1, l=arguments.length, args=[];
        while(j<l)
        {
            args.push(arguments[j++]);
        }
        var i = 0,
                il = args.length,
                key;
        for (; i < il; i++) {
            for (key in args[i]) {
                if (key === name)
                    return args[i][key]
            }
        }
    }

    function isUserLoggedIn() {
        if (questionsModel.ownUserIdValue !== "" && questionsModel.ownUserIdValue !== "signin") {
            return true
        }
        return false
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

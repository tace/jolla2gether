import QtQuick 2.0
import "../../js/askbot.js" as Askbot

ListModel {
    id: listModel

    property string webviewRelativeUrl: "../pages/WebView.qml"
    property string questionViewPageRelativeUrl: "../pages/QuestionViewPage.qml"
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
    property int numberOfVotesFilter: -1

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
    property string ownUserName: ""  // shown login info
    property string ownKarma: ""  // shown login info
    property string ownBadges: ""  // shown login info
    property string userIdSearchCriteria: ""
    property string userIdSearchFilterType: userIdSearchFilter_AUTHOR_QUESTIONS
    property string userIdSearchFilter_AUTHOR_QUESTIONS: "author"
    property string userIdSearchFilter_ANSWERED_QUESTIONS: "answered"
    property bool userQuestionsAsked: false
    property bool includeTagsChanged: false
    property bool ignoreTagsChanged: false

    // Login
    property int loginRetryCount: 0
    property int loginRetryCountMaximum: 3

    // Header
    property string pageHeader_ALL_QUESTIONS: qsTr("All questions")  // Default
    property string pageHeader_MY_QUESTIONS:  qsTr("My questions")
    property string pageHeader_FOLLOWED_QUESTIONS:  qsTr("Followed questions")
    property string pageHeader: pageHeader_ALL_QUESTIONS

    property bool loadingInProgress: false

    // Clicking external links on any page
    property string externalUrl: ""
    property bool openExternalLinkOnWebview: false
    property bool openQuestionlOnJolla2getherApp: false
    // Keep index and question ID of in-app clicked question
    property int indexOfInAppClickedQuestion: -1
    property string questionIdOfClickedTogetherLink: ""

    function refresh(page, onLoadedCallback)
    {
        clear()
        if (isUserIdSearchCriteriaActive()) {
            get_all_questions(onLoadedCallback)
        }
        else {
            get_questions(page, function(filteredCount) {
                questionsCount -= filteredCount
                if (listModel.count < 30) {
                    get_next_questions_recursive(0, onLoadedCallback, 30)
                }
                else {
                    if (onLoadedCallback)
                        onLoadedCallback(filteredCount)
                }
            })
        }
    }
    function get_nextPageQuestions(onLoadedCallback, questionAmountFilter)
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
            return false
        }
        else {
            if (questionAmountFilter) {
                if (listModel.count >= questionAmountFilter) {
                    console.log("Hit question amount filter. View already contains " + listModel.count + " questions, which is >= " + questionAmountFilter + ". Stop loading more pages!")
                    return false
                }
                console.log("Requesting questions for page " + askedPage + ", with qamountFilter " + questionAmountFilter)
                get_questions(askedPage, onLoadedCallback)
            }
            else {
                console.log("Requesting questions recursively for page " + askedPage + ", upto " + listModel.count + " + 30")
                get_next_questions_recursive(0, onLoadedCallback, listModel.count + 30)
            }
            return true
        }
    }
    function get_questions(page, onLoadedCallback)
    {
        if (!listModel.loadingInProgress) {
            Askbot.get_questions(listModel, page, onLoadedCallback)
        } else {
            console.log("Questions loading in progress, cannot request new questions now!")
        }
    }
    function update_question(questionId, index_in_model, callback) {
        Askbot.update_question(listModel, index_in_model, questionId, callback)
    }
    function get_all_questions(onLoadedCallback) {
        var totalFilterCount = 0
        get_questions(1, function(filteredCount) {
            get_next_questions_recursive(filteredCount, onLoadedCallback)
        })
    }
    function get_next_questions_recursive(currentfilteredCount, onLoadedCallback, questionAmountFilter) {
        var totalFilteredCount = currentfilteredCount
        var wasCalled = get_nextPageQuestions(function(filteredCount) {
            totalFilteredCount += filteredCount
            console.log("Got results of get_nextPageQuestions. Filtered " + filteredCount)
            get_next_questions_recursive(totalFilteredCount, undefined, questionAmountFilter)
        }, questionAmountFilter)
        if (!wasCalled) {
            console.log("Got all questions and filtered " + totalFilteredCount)
            questionsModel.questionsCount -= totalFilteredCount
            if (onLoadedCallback)
                onLoadedCallback()
        }
        else {
            console.log("Called nextPage questions...")
        }
    }

    function pushWebviewWithCustomScript(attached, props) {
        var callbacksList = []
        var properties = {}
        if ((!questionsModel.isUserLoggedIn() &&
             loginRetryCount < loginRetryCountMaximum) ||
                !attached) {
            callbacksList.push(getUserIdFromWebViewCallback())
            loginRetryCount = loginRetryCount + 1
        }
        if (pageStack.currentPage.objectName === "QuestionViewPage") {
            callbacksList.push(getVotingDataFromWebViewCallback(getQuestionId(),
                                                                pageStack.currentPage.getVotingResultsCallback()))
            callbacksList.push(getFollowedStatusFromWebViewCallback(pageStack.currentPage.followedStatusCallback))
        }
        if (pageStack.currentPage.objectName === "AnswerPage") {
            callbacksList.push(pageStack.currentPage.getAnswerDataFromWebViewCallback(true))
        }
        if (callbacksList.length > 0) {
            properties = merge(props, {callbacks: callbacksList})
        }
        else
            properties = props

        //printProps(properties)
        if (attached) {
            return pageStack.pushAttached(Qt.resolvedUrl(webviewRelativeUrl), properties)
        }
        else {
            return pageStack.push(Qt.resolvedUrl(webviewRelativeUrl), properties)
        }
    }

    function getQuestionId() {
        if (questionIdOfClickedTogetherLink !== "")
            return questionIdOfClickedTogetherLink
        return questionsModel.get(questionsModel.listViewCurrentIndex).id
    }
    function getQuestionIdOfIndex(index) {
        return questionsModel.get(index).id
    }

    function loadQuestionViewpage(questionId, index_in_model, replace, props) {
        if (questionsModel.pageHeader === questionsModel.pageHeader_FOLLOWED_QUESTIONS ||
           (index_in_model === questionsCount)) // clicked together link, add to model
        {
            if (index_in_model === questionsCount) {
                index_in_model = getInAppClickedQuestionIndex()
            }
            questionsModel.update_question(questionId, index_in_model, function() {
                if (replace)
                    pageStack.replace(Qt.resolvedUrl(questionViewPageRelativeUrl), props)
                else
                    pageStack.push(Qt.resolvedUrl(questionViewPageRelativeUrl), props)
            })
        }
        else
            if (replace)
                pageStack.replace(Qt.resolvedUrl(questionViewPageRelativeUrl), props)
            else
                pageStack.push(Qt.resolvedUrl(questionViewPageRelativeUrl), props)
    }
    function getInAppClickedQuestionIndex() {
        if (indexOfInAppClickedQuestion !== -1)
            return indexOfInAppClickedQuestion
        indexOfInAppClickedQuestion = listModel.count
        return listModel.count
    }
    function removeInAppClickedQuestionFromModel() {
        if (indexOfInAppClickedQuestion !== -1) {
            listModel.remove(indexOfInAppClickedQuestion)
        }
        indexOfInAppClickedQuestion = -1
    }

    //
    // When calling this, webview must be first directed to page
    // https://together.jolla.com/users/497/tace/?sort=favorites
    // where 497 is the userid and 'tace' is the username of the person who's
    // followed questions are fetched.
    function get_followed_questions_callback() {
        clear()
        urlLoading = true
        return function(webview) {
            var script = "(function() { \
            var content = document.getElementById('ContentFull'); \
            var divs = content.getElementsByTagName('div'); \
            var retQuestions = ''; \
            for (var i = 0; i < divs.length; i++) { \
                if (divs[i].getAttribute('class') === 'short-summary narrow') { \
                    var qId = divs[i].getAttribute('id').split('question-')[1]; \
                    retQuestions = retQuestions + qId + ','; \
                    var qTitle = divs[i].getElementsByTagName('h2')[0].getElementsByTagName('a')[0].childNodes[0].nodeValue; \
                    var counts = divs[i].getElementsByClassName('counts')[0].getElementsByTagName('div'); \
                    var qViews = ''; \
                    var qAnswers = ''; \
                    var qVotes = ''; \
                    var qUserId = ''; \
                    var qUserName = ''; \
                    var qUpdateTime = ''; \
                    for (var x = 0; x < counts.length; x++) { \
                        if (counts[x].hasAttribute('class')) { \
                            if (counts[x].getAttribute('class').substring(0, 'views'.length) === 'views') { \
                                qViews = counts[x].getElementsByClassName('item-count')[0].childNodes[0].nodeValue; \
                            } \
                            if (counts[x].getAttribute('class').substring(0, 'answers'.length) === 'answers') { \
                                qAnswers = counts[x].getElementsByClassName('item-count')[0].childNodes[0].nodeValue; \
                            } \
                            if (counts[x].getAttribute('class').substring(0, 'votes'.length) === 'votes') { \
                                qVotes = counts[x].getElementsByClassName('item-count')[0].childNodes[0].nodeValue; \
                            } \
                            if (counts[x].getAttribute('class') === 'userinfo') { \
                                var qUserInfo = counts[x].getElementsByTagName('a')[0].getAttribute('href'); \
                                qUserId = qUserInfo.split('/')[2]; \
                                qUserName = qUserInfo.split('/')[3]; \
                                qUpdateTime = counts[x].getElementsByTagName('abbr')[0].getAttribute('title'); \
                            } \
                        } \
                    } \
                    retQuestions = retQuestions + qViews + ','; \
                    retQuestions = retQuestions + qAnswers + ','; \
                    retQuestions = retQuestions + qVotes + ','; \
                    retQuestions = retQuestions + qUserId + ','; \
                    retQuestions = retQuestions + qUserName + ','; \
                    retQuestions = retQuestions + qUpdateTime + ','; \
                    var qTags = ''; \
                    var tagElems = divs[i].getElementsByClassName('tags')[0].getElementsByClassName('tag tag-right'); \
                    for (var j = 0; j < tagElems.length; j++) { \
                        if (j === 0) { \
                            qTags = tagElems[j].childNodes[0].nodeValue; \
                        } \
                        else { \
                            qTags = qTags + ' ' + tagElems[j].childNodes[0].nodeValue; \
                        } \
                    } \
                    retQuestions = retQuestions + qTags + ','; \
                    retQuestions = retQuestions + qTitle + '|_|'; \
                } \
            } \
            return retQuestions; \
            })()"
            webview.evaluateJavaScriptOnWebPage(script,  function(result) {
                //console.log("got: " + result)
                var questionsSplit = result.split('|_|')
                for (var i = 0; i < questionsSplit.length; i++) {
                    // Stats contain 8 fields: questionId,views,answers,votes,userId,userName,updateTime,tags
                    var statsPart = questionsSplit[i].split(',', 8)
                    var qId = statsPart[0]
                    if (qId.trim() === "")
                        continue
                    var qViews = statsPart[1]
                    var qAnswers = statsPart[2]
                    var qVotes = statsPart[3]
                    var qUserId = statsPart[4]
                    var qUserName = statsPart[5]
                    var qUpdateTime = statsPart[6]
                    var splittedUpdateTime = qUpdateTime.split(" ")
                    var qModUpdateTime = splittedUpdateTime[0] + "T" + splittedUpdateTime[1]
                    // Get hour part from timezone string. E.g. +0200 -> get 02
                    var timeZoneHourPart = splittedUpdateTime[2].substring(1, 3)
                    // Get + or - from timezone string
                    var timeZoneAddOrMinus = splittedUpdateTime[2].substring(0, 1)
                    var timeZonePartSeconds = parseInt(timeZoneHourPart) * 60 * 60
                    var totalUpdateTimeSeconds = parseInt(Date.parse(qModUpdateTime) / 1000)
                    if (timeZoneAddOrMinus === "+") {
                        totalUpdateTimeSeconds -= timeZonePartSeconds
                    }
                    if (timeZoneAddOrMinus === "-") {
                        totalUpdateTimeSeconds += timeZonePartSeconds
                    }
                    var qUpdateTimeDuration = Askbot.getTimeDurationAsString(totalUpdateTimeSeconds)
                    var qTags = statsPart[7]
                    // title as a last part of each question data to get it right.
                    var qTitle = questionsSplit[i].split(statsPart.join(',') + ',')[1]
                    //var presentedTime = Askbot.getTimeDurationAsString(Date.parse(qUpdateTime))
                    //console.log("presentedTime: "+presentedTime)
                    listModel.append({
                                         "id" : Number(qId),
                                         "title" : qTitle,
                                         "url" : siteBaseUrl + "/question/" + qId,
                                         "author" : qUserName,  // this is user who last updated the q
                                         "author_id" : Number(qUserId),
                                         "author_page_url" : siteBaseUrl + "/users/" + qUserId + "/" + qUserName,
                                         "answer_count" : qAnswers,
                                         "view_count" : qViews,
                                         "votes" : qVotes,
                                         "tags" : qTags.split(" ").join(','),
                                         "text": "",
                                         "has_accepted_answer": false,
                                         "closed": false,
                                         "created" : "",
                                         "updated" : qUpdateTimeDuration,
                                         "created_date" : "",
                                         "updated_date" : "",
                                     })

                }
                pagesCount = 1
                currentPageNum = 1
                questionsCount = listModel.count

                // All done, get rid of webview
                pageStack.popAttached()
                urlLoading = false
            })
        }
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
            var aelements = userElem.getElementsByTagName('a'); \
            var firstHref = aelements[0].getAttribute('href'); \
            var userId = firstHref.split('/')[2]; \
            var userName = ''; \
            var karma = ''; \
            var badges = ''; \
            if (userId !== 'signin') { \
                userName = firstHref.split('/')[3]; \
                for (var i = 0; i < aelements.length; i++) { \
                    if (aelements[i].getAttribute('class') === 'user-micro-info reputation') { \
                        karma = aelements[i].childNodes[0].nodeValue; \
                    } \
                    if (aelements[i].getAttribute('class') === 'user-micro-info') { \
                        var badgeElems = aelements[i].getElementsByTagName('span'); \
                        badges = badgeElems[0].getAttribute('title'); \
                    } \
                } \
            }; \
            return userId + '##' + userName + '##' + karma + '##' + badges; \
            })()"
            var handleResult = function(result) {
                var resData = result.split('##')
                setUserLoginInfo(resData[0].trim(), resData[1].trim(), resData[2].trim(), resData[3].trim())
                console.log( "Got userId,userName,karma,badges from webview: "
                            + questionsModel.ownUserIdValue + "##" + questionsModel.ownUserName + "##" + questionsModel.ownKarma
                            + "##" + questionsModel.ownBadges);
                if (pageStack.currentPage.objectName === "WebView") {
                    if (questionsModel.isUserLoggedIn()) {
                        pageStack.currentPage.backNavigation = true
                        pageStack.navigateBack()
                    }
                }
            }
            webview.evaluateJavaScriptOnWebPage(scriptToRun, handleResult)
        }
    }

    function logOut() {
        var scriptToRun = "(function() { \
            var userElem = document.getElementById('userToolsNav'); \
            var aelements = userElem.getElementsByTagName('a'); \
            for (var i = 0; i < aelements.length; i++) { \
                if (aelements[i].childNodes[0].nodeValue === 'sign out') { \
                    aelements[i].click(); \
                } \
            } \
            })()"
        var handleResult = function(result) {
            questionsModel.ownUserIdValue = ""
            loginRetryCount = 0
            console.log("Signed out!")
        }
        pageStack.nextPage().evaluateJavaScriptOnWebPage(scriptToRun, handleResult)
    }

    //
    // When calling this, webview must be directed first to page matching given questionId e.g.
    // https://together.jolla.com/question/59380/native-app-request-spreadsheet/ where
    // 59380 is questionId last part of url is question title.
    function getVotingDataFromWebViewCallback(questionId, votingResultsCallback) {
        console.log("called getVotingDataFromWebViewCallback with qid: " + questionId)
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

    //
    // Webpage contains following part and "button followed" has 2 div elements
    // under it if question is been followed by the user.
    //
    // <a class="button followed" alt="click to unfollow this question">
    //     <div>Following</div>
    //     <div class="unfollow">Unfollow</div>
    // </a>
    //
    function getFollowedStatusFromWebViewCallback(followedStatusCallback) {
        return function(webview) {
            var scriptToRun = "(function() { \
                        var contentRight = document.getElementById('ContentRight'); \
                        var followButton = contentRight.getElementsByTagName('a')[0]; \
                        if (followButton.getAttribute('class') === 'button followed'); \
                            return followButton.getElementsByTagName('div').length; \
                        return 0; \
                        })()"
            var handleResult = function(result) {
                console.log("Got followed status from webview. Followed: " + result)
                if (result > 0)
                    followedStatusCallback(true)
                else
                    followedStatusCallback(false)
            }
            webview.evaluateJavaScriptOnWebPage(scriptToRun, handleResult)
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
    // Return authorid as number
    function getQuestionAuthor(questionIndex) {
        return questionsModel.get(questionIndex).author_id
    }
    function isMyOwnQuestion(questionIndex) {
        if (Number(questionsModel.ownUserIdValue) === getQuestionAuthor(questionIndex)) {
            return true
        }
        return false
    }

    function setUserLoginInfo(userId, userName, karma, badges) {
        questionsModel.ownUserIdValue = userId
        questionsModel.ownUserName = userName
        if (karma !== "") {
            var tmp = karma.split(":")
            if (tmp.length === 2) {
                karma = tmp[1].trim()
            }
        }
        questionsModel.ownKarma = karma
        console.log("ORIG badges: " + badges)
        questionsModel.ownBadges = badges.split(questionsModel.ownUserName + " has ")[1]
    }
    function setUserIdSearchCriteria(userId) {
        console.log("Userid: "+userId)
        if (userId !== "" && userId !== "signin") {
            questionsModel.userIdSearchCriteria = userId
            return true
        }
        return false
    }
    function isUserIdSearchCriteriaActive() {
        return questionsModel.userIdSearchCriteria !== ""
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
        questionsModel.userIdSearchFilterType = questionsModel.userIdSearchFilter_AUTHOR_QUESTIONS
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
        c.userIdSearchFilterType = p.userIdSearchFilterType
        c.includeTagsChanged = p.includeTagsChanged
        c.ignoreTagsChanged = p.ignoreTagsChanged

        c.loginRetryCount = p.loginRetryCount

        c.pageHeader = p.pageHeader
    }
    function wiki2Html(text) {
        return Askbot.wiki2Html(text)
    }
    function rssPubDate2Seconds(rssPubDate) {
        // Qt5.2 fix (fixed in Qt5.3)
        // See: https://bugreports.qt-project.org/browse/QTBUG-38011
        //var date = new Date(rssPubDate);
        var date = dateParser.parse(rssPubDate)

        // dateParser returns date as converted to local time (e.g. to be shown in GUI),
        // but timezone information is still available.
        // To make returned seconds comparable to current time (seconds), we need to
        // change time to UTC as it's compared to current time (returned by JavaScript Date.now())
        // which is also in UTC.
        var currentDate = date;
        var currentTime = currentDate.getTime(); // this ignores timezone
        var localOffset =  date.getTimezoneOffset() * 60000; // timezone seconds
        return Math.round(new Date(currentTime + localOffset).getTime() / 1000);
    }
    function rssPubdate2ElapsedTimeString(rssPubDate) {
        var seconds = rssPubDate2Seconds(rssPubDate)
        return Askbot.getTimeDurationAsString(seconds).trim()
    }

    // Returns question status (closed/answered or both) as formatted text to be shown in ui
    function getQuestionClosedAnsweredStatusAsText(index_in_model) {
        var ret_text = ""
        if(get(index_in_model).closed) {
            ret_text = "<font color=\"lightgreen\" size=\"1\">[closed] </font>"
        }
        if (get(index_in_model).has_accepted_answer) {
            ret_text = ret_text + "<font color=\"orange\" size=\"1\">[answered] </font>"
        }
        return ret_text
    }
}

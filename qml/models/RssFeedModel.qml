import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel {
    id: rssModel
    source: ""
    query: "/rss/channel/item[contains(lower-case(child::category),lower-case(\""+commentFilter+"\")) or contains(lower-case(child::category),lower-case(\""+answerFilter+"\"))]"
    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "link"; query: "link/string()" }
    XmlRole { name: "description"; query: "description/string()" }
    XmlRole { name: "category"; query: "category/string()" }
    XmlRole { name: "pubDate"; query: "pubDate/string()"; isKey: true }

    property string rssFeedUrl
    property bool ready: false // set true when rss feed is completely loaded and models are ready to use.
    property ListModel pagingModelAnswers: ListModel {
        property int pageSize: 20 // 20 answers or comments at a time
        property int currentIndex: 0 // Keep track of point in total rss feed index
        property int pageStopIndex: 0
        property bool ready: false
    }
    property ListModel pagingModelQuestionComments: ListModel {
        property int pageSize: 20 // 20 answers or comments at a time
        property int currentIndex: 0 // Keep track of point in total rss feed index
        property int pageStopIndex: 0
        property bool ready: false
    }
    property ListModel pagingModelAnswerComments: ListModel {
        property int pageSize: 20 // 20 answers or comments at a time
        property int currentIndex: 0 // Keep track of point in total rss feed index
        property int pageStopIndex: 0
        property bool ready: false
    }
    property ListModel rssFeedForSorting: ListModel {} // needed only because WorkerScript does not support XmlListModel so have to copy all items to ListModel
    property ListModel answersRssModel: ListModel {}
    property ListModel questionCommentsRssModel: ListModel {}
    property ListModel answerCommentsRssModel: ListModel {}
    property bool answersListOpen: false
    property bool questionCommentsListOpen: false
    property bool answerCommentsListOpen: false

    property string commentFilter: "comment"
    property string answerFilter: "answer"
    property string sORT_ASC: "asc"
    property string sORT_DESC: "desc"
    property string answerId: "-1"
    property bool answerMode: false // AnswerPage active so only comments list can be used
    property WorkerScript rssFeedLoaderWorker: WorkerScript {
        source: "../../js/sorter.js"
        onMessage: {
            if(messageObject.filter === answerFilter) {
                pagingModelAnswers.ready = true
                answersRssModel.clear()
                loadAnswers()
                console.log("Answers sorted")
            }
            else {
                if (answerMode) {
                    pagingModelAnswerComments.ready = true
                    answerCommentsRssModel.clear()
                    loadAnswerComments()
                    console.log("Answer Comments sorted")
                }
                else {
                    pagingModelQuestionComments.ready = true
                    questionCommentsRssModel.clear()
                    loadQuestionComments()
                    console.log("Question Comments sorted")
                }
            }
            urlLoading = false
        }
    }

    onStatusChanged:{
        console.debug("feedSource: "+source)
        if (status === XmlListModel.Ready) {
            console.debug("feed itemcount ready: "+rssModel.count)
            var firstAnswerHit = false
            for (var i=0; i<count; i++) {
                var item = get(i)
                rssFeedForSorting.append({title: item.title,
                                          link: item.link,
                                          description: item.description,
                                          category: item.category,
                                          pubDate: item.pubDate,
                                          sortTimestamp: questionsModel.rssPubDate2Seconds(item.pubDate) // Special ts for workerscrip internal use because dateParser.parse does not work there
                                         })
            }
            urlLoading = false
            ready = true
        }
        if (status === XmlListModel.Error) {
            urlLoading = false
        }
    }
    onReadyChanged: {
        loadInitialAnswersOrComments()
    }

    function startLoadingRss() {
        source = rssFeedUrl
        urlLoading = true
    }
    function prepareForAnswer(answerNumber) {
        answerMode = true
        answerId = answerNumber
        answerCommentsListOpen = false
        pagingModelAnswerComments.ready = false
    }

    function unloadAnswer() {
        answerMode = false
        answerId = "-1"
    }

    function triggerFeedWorker(filter, order) {
        urlLoading = true
        var pagingModel
        if (filter === answerFilter) {
            pagingModel = pagingModelAnswers
        }
        if (filter === commentFilter) {
            if (answerId === "-1") {
                pagingModel = pagingModelQuestionComments
            }
            else {
                pagingModel = pagingModelAnswerComments
            }
        }

        // Have to init listmodel properties here as workerscript does not support properties for listmodels
        initPagingModel(pagingModel)
        rssFeedLoaderWorker.sendMessage({ 'rssModel': rssFeedForSorting,
                                          'pagingModel': pagingModel,
                                          'answerOrCommentFilter': filter,
                                          'sort_order': order,
                                          'answerId': answerId
                                        })
        console.log("Worker started for " + filter + " and answerId: " + answerId)
    }

    function openAnswersOrCommentsRssFeedList(answers) {
        startTime = Date.now()
        if (answers) {
            answersListOpen = !answersListOpen
            if (answersListOpen) { // Only one of the list open at a time
                questionCommentsListOpen = false
            }
        }
        else { // Comments
            if (!answerMode) {
                questionCommentsListOpen = !questionCommentsListOpen
                if (questionCommentsListOpen) { // Only one of the list open at a time
                    answersListOpen = false
                }
            }
            else {
                answerCommentsListOpen = !answerCommentsListOpen
            }
        }
        loadInitialAnswersOrComments()
    }
    function loadInitialAnswersOrComments() {
        if (ready) {
            // Load only if model ready, otherwice it's ongoing
            if (!pagingModelAnswers.ready) {
                triggerFeedWorker(answerFilter, sORT_ASC)
            }
            if (!pagingModelQuestionComments.ready) {
                triggerFeedWorker(commentFilter, sORT_ASC)
            }
            if (!pagingModelAnswerComments.ready && answerMode) {
                triggerFeedWorker(commentFilter, sORT_ASC)
            }
        }
    }
    function loadMoreAnswersOrComments() {
        if (ready) {
            // Load only if model ready, otherwice it's ongoing
            if (answersListOpen && !answerMode) {
                loadAnswers()
            }
            if (questionCommentsListOpen) {
                loadQuestionComments()
            }
            if (answerCommentsListOpen) {
                loadAnswerComments()
            }
        }
    }

    function initPagingModel(pagingModel) {
        pagingModel.currentIndex = 0
        pagingModel.pageStopIndex = 0
        pagingModel.ready = false
    }

    function loadAnswers() {
        fillRssModel(pagingModelAnswers, answersRssModel)
    }
    function loadQuestionComments() {
        fillRssModel(pagingModelQuestionComments, questionCommentsRssModel)
    }
    function loadAnswerComments() {
        fillRssModel(pagingModelAnswerComments, answerCommentsRssModel)
    }
    function getAnswersCount() {
        return answersRssModel.count
    }
    function getQuestionCommentsCount() {
        return questionCommentsRssModel.count
    }
    function getAnswerCommentsCount() {
        return answerCommentsRssModel.count
    }
    function getTotalAnswersCount() {
        return pagingModelAnswers.count
    }
    function getTotalQuestionCommentsCount() {
        return pagingModelQuestionComments.count
    }
    function getTotalAnswerCommentsCount() {
        return pagingModelAnswerComments.count
    }

    function fillRssModel(pagingModel, targetModel)
    {
        var n;
        pagingModel.pageStopIndex = pagingModel.currentIndex + pagingModel.pageSize
        if (pagingModel.pageStopIndex > pagingModel.count)
            pagingModel.pageStopIndex = pagingModel.count
        for (n=pagingModel.currentIndex; n < pagingModel.pageStopIndex; n++)
        {
            add2ListModel(pagingModel, targetModel, n)
            pagingModel.currentIndex++
        }
    }
    function pageSizeAmountItemsRead(pagingModel, index) {
        if (index === (pagingModel.pageStopIndex - 1)) {
            return true
        }
        return false
    }

    function add2ListModel(sourceModel, toModel, index) {
        toModel.append({"title":          sourceModel.get(index).title,
                           "link":           sourceModel.get(index).link,
                           "description":    sourceModel.get(index).description,
                           "category":       sourceModel.get(index).category,
                           "pubDate":        sourceModel.get(index).pubDate})
    }

}

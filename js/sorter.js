var commentFilter = "comment"
var answerFilter = "answer"
var SORT_ASC = "asc"
var SORT_DESC = "desc"

WorkerScript.onMessage = function(msg) {
    initAnswersOrCommentsModel(msg.rssModel,
                               msg.pagingModel,
                               msg.answerOrCommentFilter,
                               msg.sort_order,
                               msg.answerId)
    msg.pagingModel.sync();
    WorkerScript.sendMessage({ 'filter': msg.answerOrCommentFilter})
}

function initAnswersOrCommentsModel(rssModel,
                                    pagingModel,
                                    answerOrCommentFilter,
                                    sort_order,
                                    answerId) {
    pagingModel.clear()
    var n;
    if (answerOrCommentFilter === answerFilter) {
        for (n=0; n < rssModel.count; n++)
        {
            if (rssModel.get(n).category === answerFilter) {
                add2ListModel(rssModel, pagingModel, n)
            }
        }
    }
    else { // Comments
        // Question comments
        if (answerId === "-1") {
            for (n=0; n < rssModel.count; n++)
            {
                if (rssModel.get(n).category === commentFilter) {
                    add2ListModel(rssModel, pagingModel, n)
                }
                else {
                    // When hit first answer, all question comments are already read
                    break
                }
            }
        }
        else {
            var answerFound = false
            for (n=0; n < rssModel.count; n++)
            {
                if (!answerFound) {
                    // Find answer we want
                    if (rssModel.get(n).category === answerFilter) {
                        if (answerId === getAnswerNumber(rssModel.get(n).link)) {
                            answerFound = true
                        }
                    }
                }
                else {
                    if (rssModel.get(n).category === answerFilter) {
                        break // Some another answer
                    }
                    else {
                        // all comments of an answer are right after answer
                        add2ListModel(rssModel, pagingModel, n)
                    }
                }
            }
        }
    }
    sortListModel(pagingModel, sort_order)
}

// Returns answer or comment number from <link> url address.
// E.g. https://together.jolla.com/question/54447/telnet-communication-difficulties/?answer=54605#post-id-54605
// ==> 54605 returned
function getAnswerNumber(addressLink) {
    var lastPartSplitString = "#post-id-"
    var answerOrCommentString = answerFilter
    return addressLink.split("/?" +answerOrCommentString+ "=")[1].split(lastPartSplitString)[0]
}

function add2ListModel(sourceModel, toModel, index) {
    toModel.append({"title":          sourceModel.get(index).title,
                       "link":           sourceModel.get(index).link,
                       "description":    sourceModel.get(index).description,
                       "category":       sourceModel.get(index).category,
                       "pubDate":        sourceModel.get(index).pubDate,
                       "sortTimestamp":  sourceModel.get(index).sortTimestamp}) // sortTimestamp only used internally in workerscript
}

function sortListModel(listModel, order) {
    if (order === undefined) {
        order = SORT_ASC
    }
    console.log("sorting " + order)
    var n;
    var i;
    for (n=0; n < listModel.count; n++)
        for (i=n+1; i < listModel.count; i++)
        {
            var itemTime = listModel.get(n).sortTimestamp
            var nextItemTime = listModel.get(i).sortTimestamp
            var moveIt = false
            if (order === SORT_ASC) {
                if (itemTime > nextItemTime)
                    moveIt = true
            }
            else {
                if (itemTime < nextItemTime)
                    moveIt = true
            }
            if (moveIt)
            {
                listModel.move(i, n, 1);
                n=0;
            }
        }
}

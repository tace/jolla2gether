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
    quick_sort(pagingModel, sort_order)
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

// Slow..
//function sortListModel(listModel, order) {
//    if (order === undefined) {
//        order = SORT_ASC
//    }
//    console.log("sorting " + order)
//    var n;
//    var i;
//    for (n=0; n < listModel.count; n++)
//        for (i=n+1; i < listModel.count; i++)
//        {
//            var itemTime = listModel.get(n).sortTimestamp
//            var nextItemTime = listModel.get(i).sortTimestamp
//            var moveIt = false
//            if (order === SORT_ASC) {
//                if (itemTime > nextItemTime)
//                    moveIt = true
//            }
//            else {
//                if (itemTime < nextItemTime)
//                    moveIt = true
//            }
//            if (moveIt)
//            {
//                listModel.move(i, n, 1);
//                n=0;
//            }
//        }
//}

// qsort

function swap(listModel, a,b) {
    if (a<b) {
        listModel.move(a,b,1);
        listModel.move(b-1,a,1);
    }
    else if (a>b) {
        listModel.move(b,a,1);
        listModel.move(a-1,b,1);
    }
}

function partition(listModel, order, begin, end, pivot)
{
    var piv=listModel.get(pivot).sortTimestamp;
    swap(listModel, pivot, end-1);
    var store=begin;
    var ix;
    for(ix=begin; ix<end-1; ++ix) {
        if (order === SORT_ASC){
            if(listModel.get(ix).sortTimestamp < piv) {
                swap(listModel, store,ix);
                ++store;
            }
        }else if (order === SORT_DESC){
            if(listModel.get(ix).sortTimestamp > piv) {
                swap(listModel, store,ix);
                ++store;
            }
        }
    }
    swap(listModel, end-1, store);
    return store;
}

function qsort(listModel, order, begin, end)
{
    if(end-1>begin) {
        var pivot=begin+Math.floor(Math.random()*(end-begin));

        pivot=partition(listModel, order, begin, end, pivot);

        qsort(listModel, order, begin, pivot);
        qsort(listModel, order, pivot+1, end);
    }
}

function quick_sort(listModel, order) {
    qsort(listModel, order, 0, listModel.count)
}

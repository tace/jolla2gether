import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel {
    id: rssModel
    property ListModel pagingModel
    property ListModel sortingModel
    property string commentFilter: "comment"
    property string answerFilter: "answer"

    source: ""
    query: "/rss/channel/item[contains(lower-case(child::category),lower-case(\""+commentFilter+"\")) or contains(lower-case(child::category),lower-case(\""+answerFilter+"\"))]"
    //namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom';"

    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "link"; query: "link/string()" }
    XmlRole { name: "description"; query: "description/string()" }
    XmlRole { name: "category"; query: "category/string()" }
    XmlRole { name: "pubDate"; query: "pubDate/string()"; isKey: true }
    onStatusChanged:{
        console.debug("feedSource: "+source)
        if (status === XmlListModel.Ready) {
            console.debug("feed itemcount ready: "+rssModel.count)
            sortCommentsByTime(rssModel, pagingModel)
            fillRssModel(finalRssModel)
            finalRssModel.ready = true
            urlLoading = false
        }
        if (status === XmlListModel.Error) {
            urlLoading = false
        }
    }

    function initRssModel() {
        finalRssModel.clear()
        pagingModel.currentIndex = 0
        pagingModel.pageStopIndex = 0
    }
    function sortCommentsByTime(sourceModel, targetModel) {
        var n;
        for (n=0; n < sourceModel.count; n++)
        {
            if (sourceModel.get(n).category === commentFilter) {
                add2ListModel(sourceModel, sortingModel, n)
            }
            else {  // Answer
                // Add here comments sorted by time
                addSortedComments(sortingModel, targetModel)
                add2ListModel(sourceModel, targetModel, n)
            }
        }
        // copy possible rest of comments
        addSortedComments(sortingModel, targetModel)
    }
    function addSortedComments(sourceModel, targetModel) {
        sortListModel(sourceModel)
        copyModel(sourceModel, targetModel)
        sourceModel.clear()
    }
    function fillRssModel(listModel)
    {
        var n;
        pagingModel.pageStopIndex = pagingModel.currentIndex + pagingModel.pageSize
        if (pagingModel.pageStopIndex > pagingModel.count)
            pagingModel.pageStopIndex = pagingModel.count
        for (n=pagingModel.currentIndex; n < pagingModel.pageStopIndex; n++)
        {
            urlLoading = true
            add2ListModel(pagingModel, listModel, n)
            pagingModel.currentIndex++
        }
    }
    function sortListModel(listModel) {
        var n;
        var i;
        for (n=0; n < listModel.count; n++)
            for (i=n+1; i < listModel.count; i++)
            {
                var itemTime = questionsModel.rssPubDate2Seconds(listModel.get(n).pubDate)
                var nextItemTime = questionsModel.rssPubDate2Seconds(listModel.get(i).pubDate)
                if (itemTime > nextItemTime)
                {
                    listModel.move(i, n, 1);
                    n=0;
                }
            }
    }
    function copyModel(source, target) {
        var i;
        for (i=0; i < source.count; i++) {
            add2ListModel(source, target, i)
        }
    }
    function add2ListModel(sourceModel, toModel, index) {
        toModel.append({"title":          sourceModel.get(index).title,
                           "link":           sourceModel.get(index).link,
                           "description":    sourceModel.get(index).description,
                           "category":       sourceModel.get(index).category,
                           "pubDate":        sourceModel.get(index).pubDate})
    }
}


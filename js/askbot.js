function get_info(model)
{
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "https://together.jolla.com//api/v1/info/",true);
    xhr.onreadystatechange = function()
    {
        if ( xhr.readyState == xhr.DONE)
        {
            if ( xhr.status == 200)
            {
                var ginfo = JSON.parse(xhr.responseText);
                console.log(ginfo)
                model.append({"item" : "Groups: "+ginfo.groups})
                model.append({"item" : "Users: "+ginfo.users})
                model.append({"item" : "Questions: "+ginfo.questions})
                model.append({"item" : "Answers: "+ginfo.answers})
                model.append({"item" : "Comments: "+ginfo.comments})
            }
        }
    }
    xhr.send();

}

//
// Uses and updates properties
//      pagesCount
//      currentPage
//      questionsCount
// which are properties of main.qml
//
// Bit messy should refactor...
//
function get_questions(model, page, params, onLoadedCallback) {
    var query_params = "?"
    var isFirstParam = true
    if ((params !== undefined) && (params !== "")) {
        query_params = query_params + params
        isFirstParam = false
    }
    if ((page !== undefined) && (page !== "")) {
        // If overlimit page given just return to first page
        if (page < 1 || page > pagesCount) {
            currentPageNum = 1
        }
        else {
            currentPageNum = page
            if (isFirstParam) {
                query_params = query_params + "page=" + page
            }
            else {
                query_params = query_params + "&page=" + page
            }
            isFirstParam = false
        }
    }
    else {
        // If no page given to query it's always first page, so corrent currentPage varible
        currentPageNum = 1
    }

    // Scope: All (default) or only unanswered questions
    if (unansweredQuestionsFilter) {
        if (isFirstParam) {
            query_params = query_params + "scope=unanswered"
        }
        else {
            query_params = query_params + "&scope=unanswered"
        }
        isFirstParam = false
    }


    // searchCriteria is global and defined in main.qml
    // Order keeps persistent ones set.
    if (searchCriteria !== "") {
        if (isFirstParam) {
            query_params = query_params + "query=" + searchCriteria
        }
        else {
            query_params = query_params + "&query=" + searchCriteria
        }
        isFirstParam = false
    }

    //Tag search criteria
    if (modelSearchTagsGlobal.count > 0) {
        var tagsCriteria = ""
        for (var i = 0; i < modelSearchTagsGlobal.count; i++) {
            if (i === 0)
                tagsCriteria = modelSearchTagsGlobal.get(i).tag
            else
                tagsCriteria = tagsCriteria + "," + modelSearchTagsGlobal.get(i).tag
        }
        if (isFirstParam) {
            query_params = query_params + "tags=" + tagsCriteria
        }
        else {
            query_params = query_params + "&tags=" + tagsCriteria
        }
        isFirstParam = false
    }


    // sortingCriteria and sortingOrder are global and defined in main.qml
    // Order keeps persistent ones set.
    if (sortingCriteria !== "") {
        var sortOrder = ""
        if (sortingOrder !== "") { sortOrder = "-" + sortingOrder }
        if (isFirstParam) {
            query_params = query_params + "sort=" + sortingCriteria + sortOrder
        }
        else {
            query_params = query_params + "&sort=" + sortingCriteria + sortOrder
        }
        isFirstParam = false
    }

    //model.clear()
    pagesCount = 0
    questionsCount = 0
    get_questions_httpReq(model, query_params, onLoadedCallback)
}

function get_questions_httpReq(model, query_params, onLoadedCallback)
{
    var xhr = new XMLHttpRequest();
    var url = "https://together.jolla.com//api/v1/questions/" + query_params
    urlLoading = true
    console.log(url)
    xhr.open("GET", url, true);
    xhr.onreadystatechange = function()
    {
        if ( xhr.readyState == xhr.DONE)
        {
            if ( xhr.status == 200)
            {
                var response =  JSON.parse(xhr.responseText);

                // Pick global count values (non-page related)
                pagesCount = response.pages;
                questionsCount = response.count;
                // Fix currentpage if got less pages
                if (pagesCount < currentPageNum) {
                    currentPageNum = pagesCount
                }

                // Pick question related data
                var qs = response.questions;
                for (var index in qs)
                {
                    var ginfo = qs[index]

                    // Filter out closed questions
                    if (!closedQuestionsFilter) {
                        if (ginfo.closed)
                            continue
                    }
                    // Filter out questions with accepted answer
                    if (!answeredQuestionsFilter) {
                        if (ginfo.has_accepted_answer)
                            continue
                    }

                    model.append({"title" : ginfo.title,
                                   "url" : ginfo.url,
                                   "author" : ginfo.author.username,
                                   "answer_count" : ginfo.answer_count,
                                   "view_count" : ginfo.view_count,
                                   "votes" : ginfo.score,
                                   "tags" : ginfo.tags,
                                   "text": ginfo.text,
                                   "has_accepted_answer": ginfo.has_accepted_answer,
                                   "closed": ginfo.closed,
                                   "created" : getTimeDurationAsString(ginfo.added_at),
                                   "updated" : getTimeDurationAsString(ginfo.last_activity_at),
                                 })
                }

                // Data is loaded, call user given callback
                if (onLoadedCallback)
                    onLoadedCallback()
            }
            else
            {
                console.log("Error: " + xhr.status)
            }
            urlLoading = false
        }    
    }
    xhr.timeout = 4000;
    xhr.ontimeout = function () { console.log("Timed out!!!"); }
    xhr.send();
}


function getTimeDurationAsString(seconds) {
    return secondsToString(getCurrentTimeAsSeconds() - seconds)
}

function secondsToString(seconds)
{
    var numdays = Math.floor(seconds / 86400);
    var numhours = Math.floor((seconds % 86400) / 3600);
    var numminutes = Math.floor(((seconds % 86400) % 3600) / 60);
    var numseconds = Math.floor(((seconds % 86400) % 3600) % 60);

    var value = "";
    var onlySeconds = true
    if (numdays > 0) { value = value + numdays + "d "; onlySeconds = false; }
    if (numhours > 0) { value = value + numhours + "h "; onlySeconds = false; }
    if (numminutes > 0) { value = value + numminutes + "min "; onlySeconds = false; }
    // Leave seconds away to save space, except if only seconds
    if (onlySeconds) {
        if (numseconds > 0) { value = "now" }
    }
    else {
        value = value + "ago "
    }
    return value;
}

function getCurrentTimeAsSeconds() {
    return Date.now() / 1000;
}

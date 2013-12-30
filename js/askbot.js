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
function get_questions(model, page, params) {
    var query_params = "?"
    var isFirstParam = true
    if ((params !== undefined) && (params !== "")) {
        query_params = query_params + params
        isFirstParam = false
    }
    if ((page !== undefined) && (page !== "")) {
        // If overlimit page given just return to first page
        if (page < 1 || page > pagesCount) {
            currentPage = 1
        }
        else {
            if (isFirstParam) {
                query_params = query_params + "page=" + page
            }
            else {
                query_params = query_params + "&page=" + page
            }
            currentPage = page
            isFirstParam = false
        }
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
    }

    // Clean before fetching new values to these inside get_questions_httpReq()
    model.clear()
    pagesCount = 0
    questionsCount = 0
    get_questions_httpReq(model, query_params)
}

function get_questions_httpReq(model, query_params)
{
    var xhr = new XMLHttpRequest();
    var url = "https://together.jolla.com//api/v1/questions/" + query_params
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

                // Pick question related data
                var qs = response.questions;
                for (var index in qs)
                {
                    var ginfo = qs[index]
                    model.append({"title" : ginfo.title,
                                   "url" : ginfo.url,
                                   "author" : ginfo.author.username,
                                   "answer_count" : ginfo.answer_count,
                                   "view_count" : ginfo.view_count,
                                   "votes" : ginfo.score,
                                   "tags" : ginfo.tags,
                                   "updated" : getTimeDurationAsString(ginfo.last_activity_at),
                                 })
                }
            }
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
    if (numdays > 0) { value = value + numdays + "d " }
    if (numhours > 0) { value = value + numhours + "h " }
    if (numminutes > 0) { value = value + numminutes + "min " }
    if (numseconds > 0) { value = value + numseconds + "sec " }
    return value;
}

function getCurrentTimeAsSeconds() {
    return Date.now() / 1000;
}

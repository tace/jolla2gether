import QtQuick 2.0
import "../../js/askbot.js" as Askbot

ListModel {
    id: listModel

    // Users
    property int pagesCount: 0;
    property int currentPageNum: 1;
    property int usersCount: 0;

    // Sorting users
    property string sort_REPUTATION:    "reputation"
    property string sort_OLDEST:        "oldest"
    property string sort_RECENT:        "recent"
    property string sort_USERNAME:      "username" // API doc (http://askbot.org/doc/api.html) has bug as it's "name" there.

    property string sortingCriteriaUsers:           sort_REPUTATION;

    function refresh(page)
    {
        clear()
        get_users(page) // goes to first page if page not given
    }
    function get_nextPageUsers()
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
            get_users(askedPage)
    }
    function get_users(page)
    {
        Askbot.get_users(listModel, page)
    }

    //
    // Calls userFunc for given user (id).
    //
    // {"username": "tace",
    //  "joined_at": "1388000563",
    //  "answers": 6233,
    //  "reputation": 56,
    //  "avatar": "//www.gravatar.com/avatar/72ac79d84404549ac29ca7f70a8866f0?s=48&amp;d=identicon&amp;r=PG",
    //  "questions": 5660,
    //  "last_seen_at": "1399655072",
    //  "id": 497,
    //  "comments": 29357}
    //
    function get_user(user, userFunc)
    {
        return Askbot.get_user(user, userFunc)
    }
    function changeImageLinkSize(link, size) {
        var pattern = /(.+)\?s=[0-9]{2,2}\&(.+)/gim;
        return link
        .replace(pattern, '$1' + '?s=' + size + '&' + '$2')
    }

    //
    // When calling this, webview must be first directed to page
    // https://together.jolla.com/users/by-group/2/everyone/?t=user&query=pekka
    // where 'pekka' is the serach string used to search users
    function get_user_list_from_user_search_result_page_callback() {
        clear()
        urlLoading = true
        return function(webview) {
            var script = "(function() { \
            var retUsersData = ''; \
            var content = document.getElementById('ContentLeft'); \
            var root_list = content.getElementsByTagName('ul'); \
            if (root_list.length === 0) { \
                return 'Nothing found'; \
            } \
            var user_list_root = root_list[0]; \
            if (user_list_root.getAttribute('class') === 'user-list') { \
                var user_list = user_list_root.getElementsByTagName('li'); \
                for (var i = 0; i < user_list.length; i++) { \
                    var uId = ''; \
                    var uGravatar = ''; \
                    var uName = ''; \
                    var uKarma = ''; \
                    a_list = user_list[i].getElementsByTagName('a'); \
                    for (var k = 0; k < a_list.length; k++) { \
                        if (a_list[k].getAttribute('class') === 'avatar-box') { \
                            uId = a_list[k].getAttribute('href'); \
                            img_list = a_list[k].getElementsByTagName('img'); \
                            for (var j = 0; j < img_list.length; j++) { \
                                if (img_list[j].getAttribute('class') === 'gravatar') { \
                                    uGravatar = img_list[j].getAttribute('src'); \
                                    uName = img_list[j].getAttribute('title'); \
                                } \
                            } \
                        } \
                    } \
                    span_list = user_list[i].getElementsByTagName('span'); \
                    for (var j = 0; j < span_list.length; j++) { \
                        if (span_list[j].getAttribute('class') === 'reputation-score') { \
                            uKarma = span_list[j].childNodes[0].nodeValue; \
                        } \
                    } \
                    retUsersData = retUsersData + uId + ','; \
                    retUsersData = retUsersData + uGravatar + ','; \
                    retUsersData = retUsersData + uName + ','; \
                    retUsersData = retUsersData + uKarma + '|_|'; \
                } \
            } \
            return retUsersData; \
            })()"
            webview.evaluateJavaScriptOnWebPage(script, function(result) {
                if (result !== undefined) {
                    listModel.pagesCount = 1
                    listModel.currentPageNum = 1
                    listModel.usersCount = 0
                    if (result !== "Nothing found") {
                        var usersSplit = result.split('|_|')
                        for (var i = 0; i < usersSplit.length; i++) {
                            // Stats contain 4 fields: userId,gravatar,username,karma
                            var statsPart = usersSplit[i].split(',', 4)
                            var userId = statsPart[0].split("/")[2]  // Userid in format "/users/856/pekkap/"
                            if (userId.trim() === "")
                                continue
                            var gravatar = statsPart[1]
                            var username = statsPart[2]
                            var karma = statsPart[3]
                            console.log("Found user: " + userId + "," + username + "," + karma + "," + gravatar)
                            listModel.append({
                                                 "id" : Number(userId),
                                                 "username" : username,
                                                 "avatar_url" : "https:" + gravatar,
                                                 "reputation" : Number(karma),
                                                 "url" : siteBaseUrl + "/users/" + userId + "/" + username,
                                            })
                            listModel.usersCount += 1
                        }
                    }
                    else {
                        console.log("No users found!")
                    }
                }
                urlLoading = false
            })
        }
    }

}

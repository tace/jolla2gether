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
}

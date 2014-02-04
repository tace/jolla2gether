import QtQuick 2.0
import "../../js/askbot.js" as Askbot

QtObject {
    id: infoModel

    property int groups: 0
    property int users: 0
    property int questions: 0
    property int answers: 0
    property int comments: 0

    function get_info() {
        Askbot.get_info(infoModel)
    }
}

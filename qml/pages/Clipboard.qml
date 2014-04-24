import QtQuick 2.0

TextEdit {
    visible: false
    function setClipboard(value) {
        text = value
        selectAll()
        copy()
    }
    function getClipboard() {
        text = ""
        paste()
        return text
    }
}


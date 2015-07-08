import QtQuick 2.0

Item {
    id: ctrlHandler
    property int key
    property bool ctrlDown: false
    signal ctrlKeyPressed

    Keys.onPressed: {
        if (event.key === Qt.Key_Control) {
            console.log("Ctrl down");
            ctrlDown = true
        }
        if (event.key === key) {
            if (ctrlDown) {
                console.log("Ctrl + " + key + " pressed");
                ctrlKeyPressed()
                ctrlDown = false
                event.accepted = true;
            }
        }
    }
    Keys.onReleased: {
        if (event.key === Qt.Key_Control) {
            console.log("Ctrl up");
            ctrlDown = false
        }
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    onStatusChanged: {
        if (status === Cover.Activating) {
            coverProxy.start()
        }
        if (status === Cover.Inactive) {
            coverProxy.stop()
        }
    }

    Image {
        anchors.bottom: parent.bottom
        source: appicon
        opacity: 0.1
    }

    Column {
        visible: coverProxy.mode === coverProxy.mode_INFO

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        width: parent.width

        Item {
            width: parent.width
            height: childrenRect.height

            Label {
                id: headerLabel
                anchors.horizontalCenter: parent.horizontalCenter
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: coverProxy.header
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: headerLabel.bottom
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "total number of"
            }
        }

        Separator {
            width: parent.width
            horizontalAlignment: Qt.AlignCenter
            color: Theme.secondaryColor
        }

        Item {
            width: 1
            height: Theme.paddingSmall
        }

//        Label {
//            width: parent.width
//            color: Theme.highlightColor
//            font.pixelSize: Theme.fontSizeSmall
//            text: "Groups: " + infoModel.groups
//        }
        Label {
            width: parent.width
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            text: "Users: " + infoModel.users
        }
        Label {
            width: parent.width
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            text: "Questions: " + infoModel.questions
        }
        Label {
            width: parent.width
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            text: "Answers: " + infoModel.answers
        }
        Label {
            width: parent.width
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            text: "Comments: " + infoModel.comments
        }
    }

    Column {
        visible: coverProxy.mode === coverProxy.mode_QUESTIONS

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        width: parent.width

        Item {
            width: parent.width
            height: childrenRect.height

            Label {
                id: titleLabel
                anchors.horizontalCenter: parent.horizontalCenter
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: coverProxy.header
            }

            Label {
                id: questionsLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: titleLabel.bottom
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "question: " + coverProxy.currentQuestion + "/" + coverProxy.questionsCount
            }
            Label {
                id: pageLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: questionsLabel.bottom
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "pages loaded: " + coverProxy.currentPage + "/" + coverProxy.pageCount
            }
        }

        Separator {
            width: parent.width
            horizontalAlignment: Qt.AlignCenter
            color: Theme.secondaryColor
        }

        Item {
            width: 1
            height: Theme.paddingSmall
        }

        Label {
            width: parent.width
            color: Theme.highlightColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeSmall
            maximumLineCount: 6
            text: coverProxy.title
        }
    }


    // [previous] and [next]
    CoverActionList {
        enabled: coverProxy.hasPrevious &&
                 coverProxy.hasNext &&
                 coverProxy.mode === coverProxy.mode_QUESTIONS

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                coverProxy.previousItem();
            }
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                coverProxy.nextItem();
            }
        }
    }

    // [previous] only
    CoverActionList {
        enabled: coverProxy.hasPrevious &&
                 ! coverProxy.hasNext &&
                 coverProxy.mode === coverProxy.mode_QUESTIONS

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                coverProxy.previousItem();
            }
        }
    }

    // [refresh only]
    CoverActionList {
        enabled: ! coverProxy.hasPrevious &&
                 ! coverProxy.hasNext ||
                 coverProxy.mode === coverProxy.mode_INFO

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                coverProxy.refresh()
            }
        }
    }

    // [refresh] and [next]
    CoverActionList {
        enabled: ! coverProxy.hasPrevious &&
                 coverProxy.hasNext &&
                 coverProxy.mode === coverProxy.mode_QUESTIONS

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                coverProxy.refresh()
            }
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                coverProxy.nextItem();
            }
        }
    }
}



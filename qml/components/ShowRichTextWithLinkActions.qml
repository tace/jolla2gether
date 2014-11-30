import QtQuick 2.0
import Sailfish.Silica 1.0

ShowRichText {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Theme.paddingMedium
    anchors.rightMargin: Theme.paddingMedium

    color: Theme.primaryColor
    text: ""
    property var textBanner

    onLinkActivated: {
        var props = {
            "url": link
        }
        var dialog = pageStack.push(Qt.resolvedUrl("ExternalLinkDialog.qml"), props);
        dialog.accepted.connect(function() {
            if (dialog.selectedAction === dialog.selected_WEBVIEW) {
                openExternalLinkOnWebview = true
                externalUrl = link
                textBanner.showText(qsTr("Opening link to webview"))
            }
            if (dialog.selectedAction === dialog.selected_BROWSER) {
                textBanner.showText(qsTr("Opening link with default browser"))
            }
            if (dialog.selectedAction === dialog.selected_COPYCLIPBOARD) {
                textBanner.showText(qsTr("Link copied to clipboard"))
            }
            if (dialog.selectedAction === dialog.selected_SAVETOGALLERY) {
                if (dialog.imageSaveSuccess)
                    textBanner.showText(qsTr("Image saved to gallery"))
                else
                    textBanner.showText(qsTr("Failed to save image to gallery!"))
            }
            if (dialog.selectedAction === dialog.selected_JOLLA2GETHER) {
                openQuestionlOnJolla2getherApp = true
                questionsModel.questionIdOfClickedTogetherLink = link.split("/")[4]
                textBanner.showText(qsTr("Opening link with jolla2gether app"))
            }
        })
    }
}

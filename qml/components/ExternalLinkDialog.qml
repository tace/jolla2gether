import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    allowedOrientations: Orientation.All
    property string url
    property string selectedAction: ""
    property bool imageSaveSuccess: false
    property bool isImageUrl: isImage(url)
    property bool isTogetherQuestionUrl: isQuestionUrl(url)

    // Action constants
    property string selected_WEBVIEW: "webview"
    property string selected_BROWSER: "browser"
    property string selected_COPYCLIPBOARD : "copytoclipboard"
    property string selected_SAVETOGALLERY: "savetogallery"
    property string selected_JOLLA2GETHER: "jolla2getherapp"

    Column {
        spacing: 2
        width: parent.width

        DialogHeader {
            title: qsTr("Clicked link")
            acceptText: qsTr("Action");
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.highlightColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: url
        }

        TextSwitch {
            id: jolla2getherapp
            visible: isTogetherQuestionUrl
            automaticCheck: false
            text: qsTr("Open with jolla2gether app")
            description: qsTr("Replaces currently opened question")
            onClicked: {
                jolla2getherapp.checked = true
                webview.checked = false
                browser.checked = false
                copyLink.checked = false
                saveImage.checked = false
            }
        }
        TextSwitch {
            id: webview
            automaticCheck: false
            text: qsTr("Open with webview")
            onClicked: {
                webview.checked = true
                jolla2getherapp.checked = false
                browser.checked = false
                copyLink.checked = false
                saveImage.checked = false
            }
        }
        TextSwitch {
            id: browser
            automaticCheck: false
            text: qsTr("Open with default browser")
            onClicked: {
                browser.checked = true
                jolla2getherapp.checked = false
                webview.checked = false
                copyLink.checked = false
                saveImage.checked = false
            }
        }
        TextSwitch {
            id: copyLink
            automaticCheck: false
            text: qsTr("Copy to clipboard")
            onClicked: {
                copyLink.checked = true
                jolla2getherapp.checked = false
                browser.checked = false
                webview.checked = false
                saveImage.checked = false
            }
        }
        TextSwitch {
            id: saveImage
            automaticCheck: false
            visible: isImageUrl
            text: qsTr("Save image to gallery")
            onClicked: {
                saveImage.checked = true
                jolla2getherapp.checked = false
                browser.checked = false
                webview.checked = false
                copyLink.checked = false
            }
        }
        Separator {
            visible: isImageUrl
            width: parent.width
            horizontalAlignment: Qt.AlignCenter
            color: Theme.secondaryHighlightColor
        }

        Canvas {
            id: imageCanvas
            visible: isImageUrl
            width: imgLoader.sourceSize.width
            height: imgLoader.sourceSize.height
            renderStrategy: Canvas.Immediate
            onPaint: {
                var ctx = getContext("2d")
                ctx.drawImage(imgLoader, 0, 0)
            }
        }
        Image {
            id: imgLoader
            visible: false
            source: isImageUrl ? url : ""
        }

    }
    Component.onCompleted: {     
        if (isTogetherQuestionUrl)
            jolla2getherapp.checked = true
        else
            webview.checked = true
    }

    onAccepted: {
        if (webview.checked) {
            siteURL = url
            selectedAction = selected_WEBVIEW
        }
        if (browser.checked) {
            selectedAction = selected_BROWSER
            Qt.openUrlExternally(url)
        }
        if (copyLink.checked) {
            selectedAction = selected_COPYCLIPBOARD
            Clipboard.text = url
        }
        if (saveImage.checked) {
            var fileName = pictureGalleryDirectoryLocation + "/" + getFilenameFromUrl(url)
            if (imageCanvas.save(fileName)) {
                console.log(fileName  +" image saving succeeded!")
                imageSaveSuccess = true
            }
            else {
                console.log(fileName  +" image saving failed!")
                imageSaveSuccess = false
            }
            selectedAction = selected_SAVETOGALLERY
        }
        if (jolla2getherapp.checked) {
            selectedAction = selected_JOLLA2GETHER
        }
    }
    function getFilenameFromUrl(url) {
        return url.split("/").pop()
    }

    function isImage(link) {
        if (strEndsWith(link, ".jpg"))
            return true
        if (strEndsWith(link, ".png"))
            return true
        if (strEndsWith(link, ".svg"))
            return true
        return false
    }
    function strEndsWith(str, suffix) {
        return str.indexOf(suffix, str.length - suffix.length) !== -1
    }
    function isQuestionUrl(url) {
        var pattern = /http[s]?:\/\/together\.jolla\.com\/question\/\d+\/([^\/]+\/?)?/;
        var match = url.match(pattern)
        if (match !== null) {
            if (match[0] === url) {
                console.log("Clicked url is together.com question url")
                return true
            }
        }
        return false
    }
}

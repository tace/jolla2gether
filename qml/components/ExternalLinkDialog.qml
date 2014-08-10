import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {

    property string url
    property string selectedAction: selected_WEBVIEW
    property bool imageSaveSuccess: false
    property bool isImageUrl: isImage(url)

    // Action constants
    property string selected_WEBVIEW: "webview"
    property string selected_BROWSER: "browser"
    property string selected_COPYCLIPBOARD : "copytoclipboard"
    property string selected_SAVETOGALLERY: "savetogallery"

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
            id: webview
            automaticCheck: false
            text: qsTr("Open with webview")
            onClicked: {
                webview.checked = true
                browser.checked = false
                copyLink.checked = false
                saveImage.checked = false
                selectedAction = selected_WEBVIEW
            }
        }
        TextSwitch {
            id: browser
            automaticCheck: false
            text: qsTr("Open with default browser")
            onClicked: {
                browser.checked = true
                webview.checked = false
                copyLink.checked = false
                saveImage.checked = false
                selectedAction = selected_BROWSER
            }
        }
        TextSwitch {
            id: copyLink
            automaticCheck: false
            text: qsTr("Copy to clipboard")
            onClicked: {
                copyLink.checked = true
                browser.checked = false
                webview.checked = false
                saveImage.checked = false
                selectedAction = selected_COPYCLIPBOARD
            }
        }
        TextSwitch {
            id: saveImage
            automaticCheck: false
            visible: isImageUrl
            text: qsTr("Save image to gallery")
            onClicked: {
                saveImage.checked = true
                browser.checked = false
                webview.checked = false
                copyLink.checked = false
                selectedAction = selected_SAVETOGALLERY
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
            renderStrategy: Canvas.Cooperative
            onPaint: {
                var ctx = getContext("2d")
                ctx.drawImage(imgLoader, 0, 0)
                console.log("Canvas onPainted triggered")
            }
            onPainted: {
                console.log("Canvas painted ready")
            }
            onImageLoaded: {
                console.log("Canvas image loaded")
            }

            Component.onCompleted: {
                console.log("Canvas loaded")
            }
        }
        Image {
            id: imgLoader
            visible: false
            source: isImageUrl ? url : ""
        }

    }
    Component.onCompleted: {
        // set default as webview
        webview.checked = true
    }

    onAccepted: {
        if (webview.checked) {
            siteURL = url
        }
        if (browser.checked) {
            Qt.openUrlExternally(url)
        }
        if (copyLink.checked) {
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
        return false
    }
    function strEndsWith(str, suffix) {
        return str.indexOf(suffix, str.length - suffix.length) !== -1
    }
}

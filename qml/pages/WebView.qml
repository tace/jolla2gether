import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0

Page {
    id: webviewPage
    objectName: "WebView"
    allowedOrientations: Orientation.All
    property string browseBackText: "Back"
    property bool showUrlLoadingProgressCircle: false
    forwardNavigation: false
    property var callbacks: null

    SilicaWebView {
        id: webview
        width: parent.width
        height: parent.height
        url: siteURL
        overridePageStackNavigation: true
        focus: true
        Keys.onEscapePressed: {
            pageStack.navigateBack()
        }

        onLoadingChanged:
        {
            if (loadRequest.status === WebView.LoadStartedStatus)
                setUrlLoadding(true)
            else
                setUrlLoadding(false)
            if (loadRequest.status === WebView.LoadSucceededStatus) {
                console.log("webview succeeded to load url " + url)
                setUrlLoadding(false)
                //webview.forceActiveFocus()
                if (callbacks !== null){
                    for (var i=0; i < callbacks.length; i++) {
                        console.log("run callback in webview")
                        // Callback function can expect webview page as a parameter
                        // so function can use e.g. evaluateJavaScriptOnWebPage for running
                        // javascript in webpage
                        callbacks[i](webviewPage)
                    }
                }
            }
        }
        onNavigationRequested: {
            // detect URL scheme prefix, most likely an external link
            var schemaRE = /^\w+:/;
            if (schemaRE.test(request.url)) {
                request.action = WebView.AcceptRequest;
            } else {
                request.action = WebView.IgnoreRequest;
                // delegate request.url here
            }
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Open with default browser")
                onClicked: Qt.openUrlExternally(siteURL)
            }
            MenuItem {
                text: qsTr("Goto together.jolla.com")
                onClicked: siteURL = siteBaseUrl
            }
            MenuItem {
                enabled: webview.canGoBack
                text: qsTr("Back in webview")
                onClicked: webview.goBack()
            }
            MenuItem {
                text: qsTr("Copy url")
                onClicked: Clipboard.text = siteURL
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: webview.reload()
            }
            MenuItem {
                text: qsTr(browseBackText)
                onClicked: {
                    setBackNavigation(true)
                    pageStack.navigateBack()
                    setBackNavigation(false)
                }
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active) {
            setBackNavigation(false)
        }
        if (status === PageStatus.Inactive) {
            // Just to stop the ProgressCircle animation
            setUrlLoadding(false)
            setBackNavigation(true)
        }
    }

    function setBackNavigation(flag) {
        if (!(appSettings.webview_swipe_back_enabled_value && !flag))
            backNavigation = flag
    }
    function setUrlLoadding(flag) {
        if (showUrlLoadingProgressCircle) {
            urlLoading = flag
        }
        if (!flag)
            urlLoading = false
    }

    function evaluateJavaScriptOnWebPage(script, onReadyCallback) {
        //console.log("Running script in webview:  " + script)
        webview.experimental.evaluateJavaScript(script, onReadyCallback);
    }

}




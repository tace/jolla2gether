import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0

Page {
    id: webviewPage
    allowedOrientations: Orientation.All
    property string pageName: "WebView"
    property string browseBackText: "Back"
    property string customJavaScriptToExecute: ""
    property var customJavaScriptResultHandler: null
    forwardNavigation: false

    SilicaWebView {
        id: webview
        url: siteURL
        overridePageStackNavigation: true
        width: webviewPage.orientation === Orientation.Portrait ? 540 : 960
        height: webviewPage.orientation === Orientation.Portrait ? 960 : 540
        onLoadingChanged:
        {
            if (loadRequest.status === WebView.LoadStartedStatus)
                urlLoading = true;
            else
                urlLoading = false;
            if (loadRequest.status === WebView.LoadSucceededStatus) {
                urlLoading = false;
                webviewPage.forceActiveFocus()
            }
            if (!loading && customJavaScriptToExecute !== "" && loadRequest.status === WebView.LoadSucceededStatus) {
                webview.experimental.evaluateJavaScript(customJavaScriptToExecute, customJavaScriptResultHandler);
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
                text: qsTr("together.jolla.com main page")
                onClicked: siteURL = siteBaseUrl
            }
            MenuItem {
                text: qsTr("Copy url")
                onClicked: Clipboard.text = siteURL
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
    FancyScrollerForWebView {
        flickable: webview
        anchors.fill: webview
    }
    onStatusChanged: {
        if (status === PageStatus.Active) {
            setBackNavigation(false)
        }
        if (status === PageStatus.Inactive) {
            // Just to stop the ProgressCircle animation
            urlLoading = false
            setBackNavigation(true)
        }
    }

    function setBackNavigation(flag) {
        if (!(appSettings.webview_swipe_back_enabled_value && !flag))
            backNavigation = flag
    }
}




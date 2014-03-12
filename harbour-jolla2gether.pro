# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-jolla2gether

CONFIG += sailfishapp webkit

SOURCES += src/harbour-jolla2gether.cpp

OTHER_FILES += qml/harbour-jolla2gether.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-jolla2gether.spec \
    rpm/harbour-jolla2gether.yaml \
    harbour-jolla2gether.desktop \
    js/askbot.js \
    qml/pages/AboutPage.qml \
    qml/pages/QuestionDelegate.qml \
    qml/pages/InfoPage.qml \
    harbour-jolla2gether.png \
    harbour-jolla2gether.svg \
    qml/pages/WebView.qml \
    qml/pages/CreditsModel.qml \
    qml/pages/LicensePage.qml \
    qml/pages/SearchPage.qml \
    qml/pages/FilterPage.qml \
    qml/pages/FancyScroller.qml \
    qml/pages/UsersPage.qml \
    qml/pages/UserDelegate.qml \
    qml/pages/QuestionsPage.qml \
    qml/pages/SortUsers.qml \
    qml/pages/SortQuestions.qml \
    qml/pages/SearchUsers.qml \
    qml/pages/QuestionsModel.qml \
    qml/pages/UsersModel.qml \
    qml/pages/InfoModel.qml \
    qml/pages/FancyScrollerForWebView.qml


js.files = js
js.path = /usr/share/$${TARGET}
INSTALLS+=js
RESOURCES += \
    qrc.qrc

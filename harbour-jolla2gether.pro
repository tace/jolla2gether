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
    qml/pages/UsersPage.qml \
    qml/pages/UserDelegate.qml \
    qml/pages/QuestionsPage.qml \
    qml/pages/SortUsers.qml \
    qml/pages/SearchUsers.qml \
    qml/pages/SearchQuestions.qml \
    qml/pages/QuestionsModel.qml \
    qml/pages/UsersModel.qml \
    qml/pages/InfoModel.qml \
    qml/pages/TagSearch.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/Settings.qml \
    qml/pages/QuestionViewPage.qml \
    js/Markdown.Converter.js \
    qml/pages/AnswersAndCommentsDelegate.qml \
    qml/components/ItemFlowColumn.qml \
    qml/pages/SelectTags.qml \
    qml/components/ExternalLinkDialog.qml \
    qml/components/ShowRichText.qml \
    qml/components/ShowRichTextWithLinkActions.qml \
    qml/components/InfoBanner.qml \
    qml/components/DynamicTextRectangle.qml \
    qml/components/StatsRectangle.qml \
    qml/components/StatsRow.qml \
    qml/models/RssFeedModel.qml \
    qml/components/SearchBanner.qml \
    qml/components/VotingButton.qml \
    qml/components/QuestionTypeSelector.qml

js.files = js
js.path = /usr/share/$${TARGET}
INSTALLS+=js
RESOURCES += \
    qrc.qrc

HEADERS += \
    src/settings.h

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

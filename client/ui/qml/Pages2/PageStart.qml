import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

import PageEnum 1.0
import Style 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"
import "../Components"

PageType {
    id: root

    defaultActiveFocusItem: null

    property bool isControlsDisabled: false
    property bool isTabBarDisabled: false

    Connections {
        target: PageController

        function onGoToPageHomeRequired() {
            if (PageController.isStartPageVisible()) {
                tabBar.visible = false
                tabBarStackView.goToTabBarPage(PageEnum.PageSetupWizardStart)
            } else {
                tabBar.visible = true
                tabBar.setCurrentIndex(0)
                tabBarStackView.goToTabBarPage(PageEnum.PageHome)
            }
        }

        function onGoToPageSettingsRequired() {
            tabBar.setCurrentIndex(2)
            tabBarStackView.goToTabBarPage(PageEnum.PageSettings)
        }

        function onGoToPageViewConfigRequired() {
            var pagePath = PageController.getPagePath(PageEnum.PageSetupWizardViewConfig)
            tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.PushTransition)
        }

        function onDisableControlsRequired(disabled) {
            isControlsDisabled = disabled
        }

        function onDisableTabBarRequired(disabled) {
            isTabBarDisabled = disabled
        }

        function onClosePageRequired() {
            if (tabBarStackView.depth <= 1) {
                PageController.hideWindow()
                return
            }
            tabBarStackView.pop()
        }

        function onGoToPageRequired(page, slide) {
            var pagePath = PageController.getPagePath(page)

            if (slide) {
                tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.PushTransition)
            } else {
                tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.Immediate)
            }
        }

        function onGoToStartPageRequired() {
            while (tabBarStackView.depth > 1) {
                tabBarStackView.pop()
            }
        }

        function onEscapePressed() {
            if (root.isControlsDisabled || root.isTabBarDisabled) {
                return
            }

            var pageName = tabBarStackView.currentItem.objectName
            if ((pageName === PageController.getPagePath(PageEnum.PageShare)) ||
                    (pageName === PageController.getPagePath(PageEnum.PageSettings)) ||
                    (pageName === PageController.getPagePath(PageEnum.PageSetupWizardConfigSource))) {
                PageController.goToPageHomeRequired()
            } else {
                PageController.closePageRequired()
            }
        }

        function onForceTabBarActiveFocusRequired() {
            homeTabButton.focus = true
            tabBar.forceActiveFocus()
        }

        function onForceStackActiveFocusRequired() {
            homeTabButton.focus = true
            tabBarStackView.forceActiveFocus()
        }
    }

    Connections {
        target: InstallController

        function onInstallationErrorOccurred(error) {
            PageController.showBusyIndicatorRequired(false)

            PageController.showErrorMessage(error)

            var needCloseCurrentPage = false
            var currentPageName = tabBarStackView.currentItem.objectName

            if (currentPageName === PageController.getPagePath(PageEnum.PageSetupWizardInstalling)) {
                needCloseCurrentPage = true
            } else if (currentPageName === PageController.getPagePath(PageEnum.PageDeinstalling)) {
                needCloseCurrentPage = true
            }
            if (needCloseCurrentPage) {
                PageController.closePageRequired()
            }
        }

        function onUpdateContainerFinished(message) {
            PageController.showNotificationMessageRequired(message)
            PageController.closePageRequired()
        }

        function onCachedProfileCleared(message) {
            PageController.showNotificationMessageRequired(message)
        }

        function onApiConfigRemoved(message) {
            PageController.showNotificationMessageRequired(message)
        }

        function onInstallServerFromApiFinished(message) {
            PageController.showBusyIndicatorRequired(false)
            if (!ConnectionController.isConnected) {
                ServersModel.setDefaultServerIndex(ServersModel.getServersCount() - 1);
                ServersModel.processedIndex = ServersModel.defaultIndex
            }

            PageController.goToPageHomeRequired()
            PageController.showNotificationMessageRequired(message)
        }

        function onChangeApiCountryFinished(message) {
            PageController.showBusyIndicatorRequired(false)

            PageController.goToPageHomeRequired()
            PageController.showNotificationMessageRequired(message)
        }

        function onReloadServerFromApiFinished(message) {
            PageController.goToPageHomeRequired()
            PageController.showNotificationMessageRequired(message)
        }
    }

    Connections {
        target: ConnectionController

        function onReconnectWithUpdatedContainer(message) {
            PageController.showNotificationMessageRequired(message)
            PageController.closePageRequired()
        }

        function onNoInstalledContainers() {
            PageController.setTriggeredByConnectButton(true)

            ServersModel.processedIndex = ServersModel.getDefaultServerIndex()
            InstallController.setShouldCreateServer(false)
            PageController.goToPageRequired(PageEnum.PageSetupWizardEasy)
        }
    }

    Connections {
        target: ImportController

        function onImportErrorOccurred(error, goToPageHome) {
            PageController.showErrorMessage(error)
        }

        function onRestoreAppConfig(data) {
            PageController.showBusyIndicatorRequired(true)
            SettingsController.restoreAppConfigFromData(data)
            PageController.showBusyIndicatorRequired(false)
        }
    }

    Connections {
        target: SettingsController

        function onLoggingDisableByWatcher() {
            PageController.showNotificationMessageRequired(qsTr("Logging was disabled after 14 days, log files were deleted"))
        }

        function onRestoreBackupFinished() {
            PageController.showNotificationMessageRequired(qsTr("Settings restored from backup file"))
            PageController.goToPageHomeRequired()
        }
    }

    StackViewType {
        id: tabBarStackView

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: tabBar.top

        enabled: !root.isControlsDisabled

        function goToTabBarPage(page) {
            var pagePath = PageController.getPagePath(page)
            tabBarStackView.clear(StackView.Immediate)
            tabBarStackView.replace(pagePath, { "objectName" : pagePath }, StackView.Immediate)
        }

        Component.onCompleted: {
            var pagePath
            if (PageController.isStartPageVisible()) {
                tabBar.visible = false
                pagePath = PageController.getPagePath(PageEnum.PageSetupWizardStart)
            } else {
                tabBar.visible = true
                pagePath = PageController.getPagePath(PageEnum.PageHome)
                ServersModel.processedIndex = ServersModel.defaultIndex
            }

            tabBarStackView.push(pagePath, { "objectName" : pagePath })
        }

        Keys.onPressed: function(event) {
            PageController.keyPressEvent(event.key)
            event.accepted = true
        }
    }

    TabBar {
        id: tabBar
        objectName: "tabBar"
        activeFocusOnTab: true

        property Item upKeyTarget : tabBarStackView.currentItem
        property Item downKeyTarget: tabBarStackView.currentItem

        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        topPadding: 8
        bottomPadding: 8
        leftPadding: 96
        rightPadding: 96

        height: visible ? homeTabButton.implicitHeight + tabBar.topPadding + tabBar.bottomPadding : 0

        enabled: !root.isControlsDisabled && !root.isTabBarDisabled

        background: Shape {
            width: parent.width
            height: parent.height

            ShapePath {
                startX: 0
                startY: 0

                PathLine { x: width; y: 0 }
                PathLine { x: width; y: tabBar.height - 1 }
                PathLine { x: 0; y: tabBar.height - 1 }
                PathLine { x: 0; y: 0 }

                strokeWidth: 1
                strokeColor: AmneziaStyle.color.slateGray
                fillColor: AmneziaStyle.color.onyxBlack
            }
        }

        TabImageButtonType {
            id: homeTabButton
            objectName: "homeTabButton"

            isSelected: tabBar.currentIndex === 0
            image: "qrc:/images/controls/home.svg"
            clickedFunc: function () {
                tabBarStackView.goToTabBarPage(PageEnum.PageHome)
                ServersModel.processedIndex = ServersModel.defaultIndex
                tabBar.currentIndex = 0
            }

            focus: true
            KeyNavigation.tab: shareTabButton
            KeyNavigation.right: shareTabButton
            KeyNavigation.left: plusTabButton
            KeyNavigation.up: tabBar.upKeyTarget
            KeyNavigation.down: tabBar.downKeyTarget
            Keys.onEnterPressed: this.clicked()
            Keys.onReturnPressed: this.clicked()
        }

        TabImageButtonType {
            id: shareTabButton
            objectName: "shareTabButton"

            Connections {
                target: ServersModel

                function onModelReset() {
                    var hasServerWithWriteAccess = ServersModel.hasServerWithWriteAccess()
                    shareTabButton.visible = hasServerWithWriteAccess
                    shareTabButton.width = hasServerWithWriteAccess ? undefined : 0
                }
            }

            visible: ServersModel.hasServerWithWriteAccess()
            width: ServersModel.hasServerWithWriteAccess() ? undefined : 0

            isSelected: tabBar.currentIndex === 1
            image: "qrc:/images/controls/share-2.svg"
            clickedFunc: function () {
                tabBarStackView.goToTabBarPage(PageEnum.PageShare)
                tabBar.currentIndex = 1
            }

            KeyNavigation.tab: settingsTabButton
            KeyNavigation.right: settingsTabButton
            KeyNavigation.left: homeTabButton
            KeyNavigation.up: tabBar.upKeyTarget
            KeyNavigation.down: tabBar.downKeyTarget
        }

        TabImageButtonType {
            id: settingsTabButton
            isSelected: tabBar.currentIndex === 2
            image: "qrc:/images/controls/settings-2.svg"
            clickedFunc: function () {
                tabBarStackView.goToTabBarPage(PageEnum.PageSettings)
                tabBar.currentIndex = 2
            }

            KeyNavigation.tab: plusTabButton
            KeyNavigation.right: plusTabButton
            KeyNavigation.left: shareTabButton
            KeyNavigation.up: tabBar.upKeyTarget
            KeyNavigation.down: tabBar.downKeyTarget
        }

        TabImageButtonType {
            id: plusTabButton
            isSelected: tabBar.currentIndex === 3
            image: "qrc:/images/controls/plus.svg"
            clickedFunc: function () {
                tabBarStackView.goToTabBarPage(PageEnum.PageSetupWizardConfigSource)
                tabBar.currentIndex = 3
            }

            KeyNavigation.tab: tabBar.downKeyTarget
            KeyNavigation.right: homeTabButton
            KeyNavigation.left: settingsTabButton
            KeyNavigation.up: tabBar.upKeyTarget
            KeyNavigation.down: tabBar.downKeyTarget
        }
    }
}

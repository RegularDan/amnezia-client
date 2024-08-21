#ifndef PAGECONTROLLER_H
#define PAGECONTROLLER_H

#include <QObject>
#include <QQmlEngine>

#include "core/defs.h"
#include "ui/models/servers_model.h"

namespace PageLoader
{
    Q_NAMESPACE
    enum class PageEnum {
        PageStart = 0,
        PageHome,
        PageShare,
        PageDeinstalling,

        PageSettingsServersList,
        PageSettings,
        PageSettingsServerData,
        PageSettingsServerInfo,
        PageSettingsServerProtocols,
        PageSettingsServerServices,
        PageSettingsServerProtocol,
        PageSettingsConnection,
        PageSettingsDns,
        PageSettingsApplication,
        PageSettingsBackup,
        PageSettingsAbout,
        PageSettingsLogging,
        PageSettingsSplitTunneling,
        PageSettingsAppSplitTunneling,

        PageServiceSftpSettings,
        PageServiceTorWebsiteSettings,
        PageServiceDnsSettings,
        PageServiceSocksProxySettings,

        PageSetupWizardStart,
        PageSetupWizardCredentials,
        PageSetupWizardProtocols,
        PageSetupWizardEasy,
        PageSetupWizardProtocolSettings,
        PageSetupWizardInstalling,
        PageSetupWizardConfigSource,
        PageSetupWizardTextKey,
        PageSetupWizardViewConfig,
        PageSetupWizardQrReader,
        PageSetupWizardApiServicesList,
        PageSetupWizardApiServiceInfo,

        PageProtocolOpenVpnSettings,
        PageProtocolShadowSocksSettings,
        PageProtocolCloakSettings,
        PageProtocolXraySettings,        
        PageProtocolWireGuardSettings,
        PageProtocolAwgSettings,
        PageProtocolIKev2Settings,
        PageProtocolRaw,

        PageShareFullAccess,

        PageDevMenu
    };
    Q_ENUM_NS(PageEnum)

    static void declareQmlPageEnum()
    {
        qmlRegisterUncreatableMetaObject(PageLoader::staticMetaObject, "PageEnum", 1, 0, "PageEnum", "Error: only enums");
    }
}

class PageController : public QObject
{
    Q_OBJECT
public:
    explicit PageController(const QSharedPointer<ServersModel> &serversModel, const std::shared_ptr<Settings> &settings,
                            QObject *parent = nullptr);

public slots:
    bool isStartPageVisible();
    QString getPagePath(PageLoader::PageEnum page);

    void closeWindow();
    void hideWindow();
    void keyPressEvent(Qt::Key key);

    unsigned int getInitialPageNavigationBarColor();
    void updateNavigationBarColor(const int color);

    void showOnStartup();

    bool isTriggeredByConnectButton();
    void setTriggeredByConnectButton(bool trigger);

    void closeApplication();

    void setDrawerDepth(const int depth);
    int getDrawerDepth();

  private slots:
    void onShowErrorMessageRequired(amnezia::ErrorCode errorCode);

signals:
    void goToPageRequired(PageLoader::PageEnum page, bool slide = true);
    void goToStartPageRequired();
    void goToPageHomeRequired();
    void goToPageSettingsRequired();
    void goToPageViewConfigRequired();
    void goToPageSettingsServerServicesRequired();
    void goToPageSettingsBackupRequired();

    void closePageRequired();

    void restorePageHomeStateRequired(bool isContainerInstalled = false);

    void showErrorMessageRequired(amnezia::ErrorCode);
    void showErrorMessageRequired(const QString &errorMessage);
    void showNotificationMessageRequired(const QString &message);

    void showBusyIndicatorRequired(bool visible);
    void disableControlsRequired(bool disabled);
    void disableTabBarRequired(bool disabled);

    void hideMainWindowRequired();
    void raiseMainWindowRequired();

    void showPassphraseRequestDrawerRequired();
    void passphraseRequestDrawerCloseRequired(QString passphrase);

    void escapePressed();
    void closeTopDrawerRequired();

    void forceTabBarActiveFocusRequired();
    void forceStackActiveFocusRequired();

private:
    QSharedPointer<ServersModel> m_serversModel;

    std::shared_ptr<Settings> m_settings;

    bool m_isTriggeredByConnectButton;

    int m_drawerDepth = 0;
};

#endif // PAGECONTROLLER_H

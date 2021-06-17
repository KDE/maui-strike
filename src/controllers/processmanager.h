#ifndef PROCESSMANAGER_H
#define PROCESSMANAGER_H

#include <QObject>
#include <QUrl>

class QProcess;
class ProcessManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString workingDir READ workingDir WRITE setWorkingDir NOTIFY workingDirChanged)

    Q_PROPERTY(QStringList args READ args WRITE setArgs NOTIFY argsChanged)
    Q_PROPERTY(QStringList envVar READ envVar WRITE setEnvVar NOTIFY envVarChanged)

    Q_PROPERTY(bool processRunning READ processRunning NOTIFY processRunningChanged FINAL)

    Q_PROPERTY(bool configureRunning READ configureRunning NOTIFY configureRunningChanged FINAL)
    Q_PROPERTY(bool buildRunning READ buildRunning NOTIFY buildRunningChanged FINAL)
    Q_PROPERTY(bool binaryRunning READ binaryRunning NOTIFY binaryRunningChanged FINAL)

    Q_PROPERTY(QString installPrefix READ installPrefix WRITE setInstallPrefix NOTIFY installPrefixChanged)

    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged FINAL)

public:
    explicit ProcessManager(QObject *parent = nullptr);

    void setProjectUrl(QUrl const&);

    QString workingDir() const;

    QStringList args() const;

    QStringList envVar() const;

    bool processRunning() const;

    QString installPrefix() const;

    bool configureRunning() const;

    bool buildRunning() const;

    bool binaryRunning() const;

    bool enabled() const;

public slots:
    void build();
    void configure();
    void run();

    void stopBuild();
    void stopConfigure();
    void stopRun();

    void setWorkingDir(QString workingDir);

    void setArgs(QStringList args);

    void setEnvVar(QStringList envVar);

    void setInstallPrefix(QString installPrefix);


private:
    QProcess *m_configureProcess;
    QProcess *m_buildProcess;
    QProcess *m_runProcess;

    QString m_workingDir;
    QUrl m_rootDir;
    QUrl m_projectUrl;

    QStringList m_args;

    QStringList m_envVar;

    bool m_processRunning {false};

    QString m_installPrefix;

    void buildStep();
    void configureStep();
    void runStep();

    bool m_configureRunning {false};

    bool m_buildRunning {false};

    bool m_binaryRunning {false};

    bool m_enabled {false};

signals:

    void workingDirChanged(QString workingDir);
    void argsChanged(QStringList args);
    void envVarChanged(QStringList envVar);
    void processRunningChanged(bool running);
    void installPrefixChanged(QString installPrefix);

    void outputLine(QString output);
    void configureRunningChanged(bool configureRunning);
    void buildRunningChanged(bool buildRunning);
    void binaryRunningChanged(bool binaryRunning);
    void enabledChanged(bool enabled);
};

#endif // PROCESSMANAGER_H

#ifndef PROCESSMANAGER_H
#define PROCESSMANAGER_H

#include <QObject>
#include <QUrl>

class QProcess;
class CMakeProject;
class ProcessManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList args READ args WRITE setArgs NOTIFY argsChanged)
    Q_PROPERTY(QStringList envVar READ envVar WRITE setEnvVar NOTIFY envVarChanged)

    Q_PROPERTY(bool processRunning READ processRunning NOTIFY processRunningChanged FINAL)

    Q_PROPERTY(bool configureRunning READ configureRunning NOTIFY configureRunningChanged FINAL)
    Q_PROPERTY(bool buildRunning READ buildRunning NOTIFY buildRunningChanged FINAL)
    Q_PROPERTY(bool binaryRunning READ binaryRunning NOTIFY binaryRunningChanged FINAL)

    Q_PROPERTY(QString installPrefix READ installPrefix WRITE setInstallPrefix NOTIFY installPrefixChanged)
    Q_PROPERTY(QString infoLabel READ infoLabel NOTIFY infoLabelChanged)

    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged FINAL)

public:
    explicit ProcessManager(CMakeProject *project);

    void setProjectUrl(QUrl const&);

    QUrl buildDir() const;
    QUrl rootDir() const;

    QStringList args() const;

    QStringList envVar() const;

    bool processRunning() const;

    QString installPrefix() const;

    bool configureRunning() const;

    bool buildRunning() const;

    bool binaryRunning() const;

    bool enabled() const;

    QString infoLabel() const
    {
        return m_infoLabel;
    }

public slots:
    void build();
    void configure();
    void run();

    void stopBuild();
    void stopConfigure();
    void stopRun();

    void setArgs(QStringList args);

    void setEnvVar(QStringList envVar);

    void setInstallPrefix(QString installPrefix);


private:
    CMakeProject *m_project;
    QProcess *m_configureProcess;
    QProcess *m_buildProcess;
    QProcess *m_runProcess;

    QUrl m_rootDir;
    QUrl m_buildDir;
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

    QString m_infoLabel;

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
    void infoLabelChanged(QString infoLabel);
};

#endif // PROCESSMANAGER_H

#pragma once

#include <QObject>
#include <QUrl>

class QProcess;
class CMakeProject;

class ConfigureProcess;
class ProcessManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool processRunning READ processRunning NOTIFY processRunningChanged FINAL)

    Q_PROPERTY(Status configureStatus READ configureStatus NOTIFY configureStatusChanged FINAL)
    Q_PROPERTY(Status buildStatus READ buildStatus NOTIFY buildStatusChanged FINAL)
    Q_PROPERTY(Status deployStatus READ deployStatus NOTIFY deployStatusChanged FINAL)

    Q_PROPERTY(QString infoLabel READ infoLabel NOTIFY infoLabelChanged)

    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged FINAL)

public:
  enum Status
  {
      Running,
      Finished,
      Error,
      None
  };Q_ENUM(Status)

    explicit ProcessManager(CMakeProject *project);
  ~ProcessManager();

    bool processRunning() const;

    Status configureStatus() const;

    Status buildStatus() const;

    Status  deployStatus() const;

    bool enabled() const;

    QString infoLabel() const;

public Q_SLOTS:
    void build();
    void configure();
    void deploy();

    void stopBuild();
    void stopConfigure();
    void stopDeploy();

private:
    CMakeProject *m_project;
    ConfigureProcess *m_configureProcess;
    QProcess *m_buildProcess;
    QProcess *m_deployProcess;

    bool m_processRunning {false};

    void buildStep();
    void configureStep();
    void deployStep();

    Status m_configureStatus {Status::None};

    Status m_buildStatus {Status::None};

    Status m_deployStatus {Status::None};

    bool m_enabled {false};

    QString m_infoLabel;

Q_SIGNALS:
   void processRunningChanged(bool running);

    void outputLine(QString output);

    void configureStatusChanged(Status configureStatus);
    void buildStatusChanged(Status buildStatus);
    void deployStatusChanged(Status binaryStatus);

    void enabledChanged(bool enabled);
    void infoLabelChanged(QString infoLabel);
};


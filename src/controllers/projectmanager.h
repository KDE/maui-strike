#ifndef PROJECTMANAGER_H
#define PROJECTMANAGER_H

#include <QObject>
#include <QUrl>

class ProcessManager;
class ProjectManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl projectUrl READ projectUrl WRITE setProjectUrl NOTIFY projectUrlChanged)
    Q_PROPERTY(QString projectTitle READ projectTitle NOTIFY projectTitleChanged FINAL)
    Q_PROPERTY(QString projectPath READ projectPath NOTIFY projectPathChanged FINAL)
    Q_PROPERTY(QString projectLogo READ projectLogo NOTIFY projectLogoChanged FINAL)
    Q_PROPERTY(ProcessManager * process READ processManager CONSTANT FINAL)

public:
    explicit ProjectManager(QObject *parent = nullptr);

    QUrl projectUrl() const;

    QString projectTitle() const;

    ProcessManager * processManager() const;

    QString projectPath() const;

    QString projectLogo() const;

public slots:
    void setProjectUrl(QUrl projectUrl);

private:
    QUrl m_projectUrl;

    ProcessManager *m_process;

    QString m_projectTitle {"Strike"};

    QString m_projectPath;

    QString m_projectLogo {"qrc:/img/strike.svg"};

signals:
    void projectUrlChanged(QUrl projectUrl);
    void projectTitleChanged(QString projectTitle);
    void projectPathChanged(QString projectPath);
    void projectLogoChanged(QString projectLogo);
};

#endif // PROJECTMANAGER_H

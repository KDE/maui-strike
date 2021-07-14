#ifndef PROJECTMANAGER_H
#define PROJECTMANAGER_H

#include <QObject>
#include <QUrl>

class CMakeProjectManager;

class ProjectPreferences;
class ProjectManager : public QObject
{
    Q_OBJECT
    // The root cmake file url
    Q_PROPERTY(QUrl projectUrl READ projectUrl WRITE setProjectUrl NOTIFY projectUrlChanged)

    //The root dir where the cmake file lives
    Q_PROPERTY(QUrl projectPath READ projectPath NOTIFY projectPathChanged FINAL)
    Q_PROPERTY(QString projectLogo READ projectLogo NOTIFY projectLogoChanged FINAL)

    Q_PROPERTY(ProjectPreferences * preferences READ preferences CONSTANT FINAL)
    Q_PROPERTY(CMakeProjectManager * manager READ manager CONSTANT FINAL)

public:
    explicit ProjectManager(QObject *parent = nullptr);

    QString projectLogo() const;
    QUrl projectUrl() const;
    QUrl projectPath() const;

    ProjectPreferences * preferences() const;

    CMakeProjectManager * manager() const;

public slots:
    void setProjectUrl(QUrl projectUrl);

private:
    CMakeProjectManager *m_projectManager;

    QString m_projectLogo {"qrc:/img/strike.svg"};
    QUrl m_projectUrl;
    QUrl m_projectPath;

    ProjectPreferences *m_preferences;

signals:
    void projectUrlChanged(QUrl projectUrl);
    void projectPathChanged(QUrl projectPath);
    void projectLogoChanged(QString projectLogo);
};

#endif // PROJECTMANAGER_H

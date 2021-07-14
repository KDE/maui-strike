#ifndef CMAKEPROJECTMANAGER_H
#define CMAKEPROJECTMANAGER_H

#include <QHash>
#include <QObject>

class ConfigureProcess;

class CMakeProject;
class CMakeProjectsModel;
class ProjectManager;

/**
 * @brief The CMakeProjectManager class
 * The manager handles the current CMake file projects and paths.
 * Initially the manager takes the job to create the CMAke API requests and read the response.
 *
 */
class CMakeProjectManager : public QObject
{
    Q_OBJECT   

    //The projects model
    Q_PROPERTY(CMakeProjectsModel * projectsModel READ projectsModel CONSTANT FINAL)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged FINAL)

public:
    enum Status
    {
        Loading,
        Ready,
        Error,
        None
    };Q_ENUM(Status)

    explicit CMakeProjectManager(ProjectManager *parent);

    void init();

    CMakeProjectsModel * projectsModel() const;
    Status status() const;

private:
    CMakeProjectsModel * m_projectsModel;
    ConfigureProcess *m_configureProcess;

    ProjectManager * m_project;

    QHash<QString, CMakeProject*> m_projects;
    Status m_status = Status::None;

    void initServer();
    void initConfigure();
    void initBuildDir();

    void readIndexReply();

    void setStatus(const Status &status);

signals:
    void outputLine(QString output);
    void statusChanged(Status status);
};



#endif // CMAKEPROJECTMANAGER_H

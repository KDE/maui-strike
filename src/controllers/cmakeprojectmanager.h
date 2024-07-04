#pragma once

#include <QHash>
#include <QObject>

#include "models/cmakeprojectsmodel.h"
#include "controllers/cmakeproject.h"
#include "processmanager.h"

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

    Q_PROPERTY(CMakeProject *project READ project CONSTANT FINAL)
    Q_PROPERTY(ProcessManager *process READ process CONSTANT FINAL)

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
    CMakeProject *project() const;
    ProjectManager *root();
    ProcessManager *process() const;

    Status status() const;

private:
    CMakeProjectsModel * m_projectsModel;
    CMakeProject * m_project;
    ProcessManager *m_process;
    ProjectManager * m_root;

    Status m_status = Status::None;

    void initServer();
    void initConfigure();
    void initBuildDir();

    void readIndexReply();

    void setStatus(const Status &status);

Q_SIGNALS:
    void outputLine(QString output);
    void statusChanged(Status status);
};

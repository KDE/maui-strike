#ifndef CMAKEPROJECT_H
#define CMAKEPROJECT_H

#include <QObject>
#include "cmakedata.h"

class CMakeProjectTarget;
class CMakeProjectManager;
class CMakeTargetsModel;
class CMakeProject : public QObject
{
    Q_OBJECT

    // Project title as set in the cmake project_name
    Q_PROPERTY(QString title READ title NOTIFY dataChanged FINAL)

    Q_PROPERTY(CMakeProjectData data READ data WRITE setData NOTIFY dataChanged)
    //The model of targets set in the cmake project
    Q_PROPERTY(CMakeTargetsModel *targetsModel READ targetsModel CONSTANT FINAL)

    Q_PROPERTY(CMakeProjectTarget *target READ target CONSTANT FINAL)


public:
    explicit CMakeProject(CMakeProjectManager *manager = nullptr);
    QString title() const;
    CMakeTargetsModel * targetsModel() const;
    CMakeProjectData data() const;
    CMakeProjectTarget *target() const;
    CMakeProjectManager *manager() const;

public slots:
    void setData(CMakeProjectData data);

private:
    CMakeTargetsModel *m_targetsModel;
    CMakeProjectData m_data;
    CMakeProjectTarget *m_target;
    CMakeProjectManager *m_manager;


signals:
    void dataChanged(CMakeProjectData data);
};

#endif // CMAKEPROJECT_H

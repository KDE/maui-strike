#ifndef CMAKEPROJECT_H
#define CMAKEPROJECT_H

#include <QObject>
class CMakeTargetsModel;
class CMakeProject : public QObject
{
    Q_OBJECT

    // Project title as set in the cmake project_name
    Q_PROPERTY(QString title READ title NOTIFY titleChanged FINAL)

    //The model of targets set in the cmake project
    Q_PROPERTY(CMakeTargetsModel *targetsModel READ targetsModel NOTIFY targetsModelChanged FINAL)

    QString m_title;

    CMakeTargetsModel * m_targetsModel;

public:
    explicit CMakeProject(QObject *parent = nullptr);

    QString title() const;

    CMakeTargetsModel * targetsModel() const;

signals:

    void titleChanged(QString title);
    void targetsModelChanged(CMakeTargetsModel * targetsModel);
};

#endif // CMAKEPROJECT_H

#ifndef CONFIGUREPROCESS_H
#define CONFIGUREPROCESS_H

#include <QProcess>
#include <QUrl>

class ProjectManager;
class ConfigureProcess : public QProcess
{
    Q_OBJECT
public:
    ConfigureProcess(ProjectManager *project, QObject *parent = nullptr);
    void prepare();

private:
    ProjectManager *m_project;
    void makeDir();
};

#endif // CONFIGUREPROCESS_H

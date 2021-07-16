#ifndef CONFIGUREPROCESS_H
#define CONFIGUREPROCESS_H

#include <QProcess>
#include <QUrl>

class CMakeProjectManager;
class ConfigureProcess : public QProcess
{
    Q_OBJECT
public:
    ConfigureProcess(CMakeProjectManager *parent = nullptr);
    void prepare();

private:
    CMakeProjectManager *m_project;
    void makeDir();
};

#endif // CONFIGUREPROCESS_H

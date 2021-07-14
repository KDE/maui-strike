#include "configureprocess.h"

#include <QDir>
#include <QDebug>

#include "controllers/projectmanager.h"
#include "controllers/projectpreferences.h"

ConfigureProcess::ConfigureProcess(ProjectManager * project, QObject *parent) : QProcess(parent)
  , m_project(project)
{
}

void ConfigureProcess::prepare()
{
    //set the cmake program
    this->setProgram(m_project->preferences()->cmakeProgram());

    //set the working directory aka where the build will happen
    this->setWorkingDirectory(m_project->preferences()->buildDir().toLocalFile());

    //double check the build directory exists anf if not then make it
    this->makeDir();

    //set the needed args for configuring
    //TODO add in Preferences an option to set more configure args
    const QStringList args = {m_project->projectPath().toLocalFile(), QString("-DCMAKE_INSTALL_PREFIX=%1").arg(m_project->preferences()->installPrefix())};

    this->setArguments(args);

    qDebug() << "Running cmake << " << this->program() << this->arguments() << this->workingDirectory();

}

void ConfigureProcess::makeDir()
{
    const QDir dir(this->workingDirectory());
    if(!dir.exists())
    {
        if(!dir.mkpath("."))
        {
            qWarning() << "Working directory could not be created at << " << this->workingDirectory();
            return;
        }
    }
}

#include "projectmanager.h"

#include <QDebug>
#include <QDir>

#include <MauiKit/FileBrowsing/fmstatic.h>

#include "cmakeprojectmanager.h"
#include "cmakeapi.h"

#include "projectpreferences.h"

ProjectManager::ProjectManager(QObject *parent) : QObject(parent)
  , m_projectManager(new CMakeProjectManager(this))
  , m_preferences(new ProjectPreferences(this))
{
    connect(this, &ProjectManager::projectUrlChanged, [this](QUrl)
    {
        //check cmake file actually exists
        if(!FMStatic::fileExists(m_projectUrl))
        {
            qWarning() << "CMake main file doesn't exists. Can not procced";
            return;
        }

        //from cmake file determine the source directory
        m_projectPath = FMStatic::fileDir(m_projectUrl);
        emit this->projectPathChanged(m_projectPath);

        //by default set the build directory as ./build
        m_preferences->setBuildDir(m_projectPath.toString()+"/build");

        //maybe try to load a logo form the source directory
        qDebug() << "Project Logo" << m_projectPath.toString() +"/logo.png" << FMStatic::fileExists(QUrl(m_projectPath.toString() +"/logo.png"));

        if(FMStatic::fileExists(QUrl(m_projectPath.toString() +"/logo.png")))
        {
            m_projectLogo = m_projectPath.toString() +"/logo.png";
            emit this->projectLogoChanged(m_projectLogo);
        }
    });
}

QUrl ProjectManager::projectUrl() const
{
    return m_projectUrl;
}

ProjectPreferences *ProjectManager::preferences() const
{
    return m_preferences;
}

CMakeProjectManager *ProjectManager::manager() const
{
    return m_projectManager;
}

QUrl ProjectManager::projectPath() const
{
    return m_projectPath;
}

QString ProjectManager::projectLogo() const
{
    return m_projectLogo;
}

void ProjectManager::setProjectUrl(QUrl projectUrl)
{
    if (m_projectUrl == projectUrl)
        return;

    qDebug() << "Setting up new project from " << projectUrl;

    m_projectUrl = projectUrl;
    emit projectUrlChanged(m_projectUrl);
}

void ProjectManager::configure()
{
    //when starting to configure take into account all the preferences

    //start the initial configuration of the project, like parsing and creating the needed files
    m_projectManager->init();
}

#include "projectmanager.h"
#include "processmanager.h"
#include "cmakeprojectmanager.h"

#include <QDebug>
#include <QDir>

#include <MauiKit/FileBrowsing/fmstatic.h>

ProjectManager::ProjectManager(QObject *parent) : QObject(parent)
  , m_process(new ProcessManager(this))
{
    connect(this, &ProjectManager::projectUrlChanged, [this](QUrl url)
    {
        m_process->setProjectUrl(url);
        CMake::FileApi::writeClientQueryFile(m_process->buildDir().toLocalFile());

        m_projectTitle = QDir(m_process->rootDir().toLocalFile()).dirName();
        emit this->projectTitleChanged(m_projectTitle);

        m_projectPath = FMStatic::fileDir(url).toLocalFile();
        emit this->projectPathChanged(m_projectPath);

        if(FMStatic::fileExists(QUrl::fromLocalFile(m_projectPath +"/logo.png")))
        {
            m_projectLogo = m_projectPath +"/logo.png";
            emit this->projectLogoChanged(m_projectLogo);
        }

    });
}

QUrl ProjectManager::projectUrl() const
{
    return m_projectUrl;
}

QString ProjectManager::projectTitle() const
{
    return m_projectTitle;
}

ProcessManager *ProjectManager::processManager() const
{
    return m_process;
}

QString ProjectManager::projectPath() const
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

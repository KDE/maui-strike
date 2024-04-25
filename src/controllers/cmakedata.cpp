#include "cmakedata.h"

#include <MauiKit4/FileBrowsing/fmstatic.h>

#include <QDebug>
#include <QDir>
#include <QUrl>

void CMakeFile::addDefine(const QString& define)
{
    if (define.isEmpty())
        return;
    const int eqIdx = define.indexOf(QLatin1Char('='));
    if (eqIdx < 0) {
        defines[define] = QString();
    } else {
        defines[define.left(eqIdx)] = define.mid(eqIdx + 1);
    }
}

void CMakeFilesCompilationData::rebuildFileForFolderMapping()
{
    fileForFolder.clear();
    // iterate over files and add all direct folders
    for (auto it = files.constBegin(), end = files.constEnd(); it != end; ++it)
    {
        const auto file = it.key();
        const auto folder = FMStatic::fileDir(file);

        if (fileForFolder.contains(folder))
            continue;

        fileForFolder.insert(folder, it.key());
    }
    // now also add the parents of these folders
    const auto copy = fileForFolder;
    for (auto it = copy.begin(), end = copy.end(); it != end; ++it)
    {
        auto folder = it.key();
        QDir dir(folder.toLocalFile());
        while (dir.cdUp())
        {
            //            folder = FMStatic::parentDir(folder);
            if (fileForFolder.contains(dir.absolutePath()))
            {
                break;
            }

            fileForFolder.insert(dir.absolutePath(), it.key());
        }
    }
}

CMakeTarget::Type CMakeTarget::typeToEnum(const QString& value)
{
    static const QHash<QString, CMakeTarget::Type> s_types = {
        {QStringLiteral("EXECUTABLE"), CMakeTarget::Executable},
        {QStringLiteral("STATIC_LIBRARY"), CMakeTarget::Library},
        {QStringLiteral("MODULE_LIBRARY"), CMakeTarget::Library},
        {QStringLiteral("SHARED_LIBRARY"), CMakeTarget::Library},
        {QStringLiteral("OBJECT_LIBRARY"), CMakeTarget::Library},
        {QStringLiteral("INTERFACE_LIBRARY"), CMakeTarget::Library}
    };
    return s_types.value(value, CMakeTarget::Custom);
}

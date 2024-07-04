#pragma once

#include <QHash>
#include <QList>
#include <QString>
#include <QUrl>
#include <QObject>
#include <QVector>

struct CMakeFile
{
    QList<QUrl> includes;
    QList<QUrl> frameworkDirectories;
    QString compileFlags;
    QString language;
    QString group;
    QHash<QString, QString> defines;

    void addDefine(const QString& define);

    bool isEmpty() const
    {
        return includes.isEmpty() && frameworkDirectories.isEmpty()
            && compileFlags.isEmpty() && defines.isEmpty();
    }
};
Q_DECLARE_TYPEINFO(CMakeFile, Q_MOVABLE_TYPE);

struct CMakeFilesCompilationData
{
    QHash<QUrl, CMakeFile> files;
    bool isValid = false;
    /// lookup table to quickly find a file path for a given folder path
    /// this greatly speeds up fallback searching for information on untracked files
    /// based on their folder path
    QHash<QUrl, QUrl> fileForFolder; //folder - file
    void rebuildFileForFolderMapping();
};

struct CMakeTarget
{
    Q_GADGET
public:
    enum Type { Library, Executable, Custom };
    Q_ENUM(Type)

    static Type typeToEnum(const QString& target);

    Type type;
    QString name;
    QList<QUrl> artifacts;
    QList<QUrl> sources;
    // see https://cmake.org/cmake/help/latest/prop_tgt/FOLDER.html
    QString folder;
};
Q_DECLARE_TYPEINFO(CMakeTarget, Q_MOVABLE_TYPE);

typedef QHash<QUrl, QVector<CMakeTarget>> CMakeProjectTargets;

struct CMakeProjectData
{
    QString name;
    CMakeFilesCompilationData compilationData;
    CMakeProjectTargets targets;
    struct CMakeFileFlags
    {
        bool isGenerated = false;
        bool isExternal = false;
        bool isCMake = false;
    };
    QHash<QUrl, CMakeFileFlags> cmakeFiles;
};

Q_DECLARE_METATYPE(CMakeProjectData)
Q_DECLARE_METATYPE(CMakeTarget)
Q_DECLARE_METATYPE(CMakeProjectTargets)
Q_DECLARE_METATYPE(CMakeFile)


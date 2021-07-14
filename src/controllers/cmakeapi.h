/* This file is part of KDevelop

    Copyright 2020 Milian Wolff <mail@milianw.de>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#pragma once

#include <QObject>
#include <QHash>

class QJsonObject;
class QString;
class QUrl;

struct CMakeFile
{
    QList<QUrl> includes;
    QList<QUrl> frameworkDirectories;
    QString compileFlags;
    QString language;
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
    QHash<QUrl, QUrl> fileForFolder;
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

struct CMakeProjectData
{
    QString name;
    CMakeFilesCompilationData compilationData;
    QHash<QUrl, QVector<CMakeTarget>> targets;
    struct CMakeFileFlags
    {
        bool isGenerated = false;
        bool isExternal = false;
        bool isCMake = false;
    };
    QHash<QUrl, CMakeFileFlags> cmakeFiles;
};

/// see: https://cmake.org/cmake/help/latest/manual/cmake-file-api.7.html
namespace CMake {
namespace FileApi {
/**
 * @returns true when the given @p cmakeExecutable supports the cmake-file-api, false otherwise
 */
bool supported(const QString &cmakeExecutable);

/**
 * Write the KDevelop-specific query file into the given @p buildDirectory.
 *
 * See also: https://cmake.org/cmake/help/latest/manual/cmake-file-api.7.html#v1-client-stateful-query-files
 */
void writeClientQueryFile(const QString &buildDirectory);

/**
 * Read and parse latest available reply index file that corresponds to our query in @p buildDirectory.
 *
 * See also: https://cmake.org/cmake/help/latest/manual/cmake-file-api.7.html#v1-reply-index-file
 */
QJsonObject findReplyIndexFile(const QString &buildDirectory);

/**
 * Read and parse the code model referenced by the given @p replyIndex
 *
 * See also: https://cmake.org/cmake/help/latest/manual/cmake-file-api.7.html#id11
 */
CMakeProjectData parseReplyIndexFile(const QJsonObject& replyIndex,
                                                            const QUrl& sourceDirectory,
                                                            const QUrl& buildDirectory);
}
}

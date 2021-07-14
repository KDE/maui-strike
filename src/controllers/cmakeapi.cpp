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

#include "cmakeapi.h"
#include "cmakeprojectmanager.h"

#include <MauiKit/FileBrowsing/fmstatic.h>
#include <QDebug>

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QVersionNumber>

namespace {
QUrl toCanonical(const QUrl& path)
{
    QFileInfo info(path.toLocalFile());
    if (!info.exists())
        return path;
    const auto canonical = info.canonicalFilePath();
    if (info.filePath() != canonical) {
        return QUrl(canonical);
    } else {
        return path;
    }
}

QJsonObject parseFile(const QString& path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "failed to read json file" << path << file.errorString();
        return {};
    }
    QJsonParseError error;
    const auto document = QJsonDocument::fromJson(file.readAll(), &error);
    if (error.error) {
        qWarning() << "failed to parse json file" << path << error.errorString() << error.offset;
        return {};
    }
    return document.object();
}

bool isStrikeClientResponse(const QJsonObject& indexObject)
{
    return indexObject.value(QLatin1String("reply")).toObject().contains(QLatin1String("client-strike"));
}
}

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
    for (auto it = files.constBegin(), end = files.constEnd(); it != end; ++it) {
        const auto file = it.key();
        const auto folder = FMStatic::fileDir(file);
        if (fileForFolder.contains(folder))
            continue;
        fileForFolder.insert(folder, it.key());
    }
    // now also add the parents of these folders
    const auto copy = fileForFolder;
    for (auto it = copy.begin(), end = copy.end(); it != end; ++it) {
        auto folder = it.key();
        while (folder.hasParent()) {
            folder = FMStatic::parentDir(folder);
            if (fileForFolder.contains(folder)) {
                break;
            }
            fileForFolder.insert(folder, it.key());
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

namespace CMake {
namespace FileApi {

void writeClientQueryFile(const QString& buildDirectory)
{
    const QDir queryDir(buildDirectory + QLatin1String("/.cmake/api/v1/query/client-strike/"));
    if (!queryDir.exists() && !queryDir.mkpath(QStringLiteral("."))) {
        qWarning() << "failed to create file API query dir:" << queryDir.absolutePath();
        return;
    }

    QFile queryFile(queryDir.absoluteFilePath(QStringLiteral("query.json")));
    if (!queryFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "failed to open query file for writing:" << queryFile.fileName() << queryFile.errorString();
        return;
    }

    queryFile.write(R"({"requests": [{"kind": "codemodel", "version": 2}, {"kind": "cmakeFiles", "version": 1}]})");
}

static QDir toReplyDir(const QString& buildDirectory)
{
    QDir replyDir(buildDirectory + QLatin1String("/.cmake/api/v1/reply/"));
    if (!replyDir.exists()) {
        qWarning() << "cmake-file-api reply directory does not exist:" << replyDir.path();
    }
    return replyDir;
}

QJsonObject findReplyIndexFile(const QString& buildDirectory)
{
    const auto replyDir = toReplyDir(buildDirectory);
    for (const auto& entry : replyDir.entryInfoList({QStringLiteral("index-*.json")}, QDir::Files, QDir::Name | QDir::Reversed)) {
        const auto object = parseFile(entry.absoluteFilePath());
        if (isStrikeClientResponse(object)) {
            return object;
        }
    }
    qWarning() << "no cmake-file-api reply index file found in" << replyDir.absolutePath();
    return {};
}

static CMakeTarget parseTarget(const QJsonObject& target, QUrl& sourcePathInterner, QUrl& buildPathInterner,
                               CMakeFilesCompilationData& compilationData)
{
    CMakeTarget ret;
    ret.name = target.value(QLatin1String("name")).toString();
    ret.type = CMakeTarget::typeToEnum(target.value(QLatin1String("type")).toString());
    ret.folder = target.value(QLatin1String("folder")).toObject().value(QLatin1String("name")).toString(); //?

    for (const auto& jsonArtifact : target.value(QLatin1String("artifacts")).toArray())
    {
        const auto artifact = jsonArtifact.toObject();
        const auto buildPath = buildPathInterner.internPath(artifact.value(QLatin1String("path")).toString());

        if (buildPath.isValid())
        {
            ret.artifacts.append(buildPath);
        }
    }

    for (const auto& jsonSource : target.value(QLatin1String("sources")).toArray())
    {
        const auto source = jsonSource.toObject();
        const auto sourcePath = sourcePathInterner.internPath(source.value(QLatin1String("path")).toString());
        if (sourcePath.isValid()) {
            ret.sources.append(sourcePath);
        }
    }

    QVector<CMakeFile> compileGroups;
    for (const auto& jsonCompileGroup : target.value(QLatin1String("compileGroups")).toArray()) {
        CMakeFile cmakeFile;
        const auto compileGroup = jsonCompileGroup.toObject();

        cmakeFile.language = compileGroup.value(QLatin1String("language")).toString();

        for (const auto& jsonFragment : compileGroup.value(QLatin1String("compileCommandFragments")).toArray()) {
            const auto fragment = jsonFragment.toObject();
            cmakeFile.compileFlags += fragment.value(QLatin1String("fragment")).toString();
            cmakeFile.compileFlags += QLatin1Char(' ');
        }
        cmakeFile.compileFlags = stringInterner.internString(cmakeFile.compileFlags);

        for (const auto& jsonDefine : compileGroup.value(QLatin1String("defines")).toArray()) {
            const auto define = jsonDefine.toObject();
            cmakeFile.addDefine(define.value(QLatin1String("define")).toString());
        }
//        cmakeFile.defines = MakeFileResolver::extractDefinesFromCompileFlags(cmakeFile.compileFlags, stringInterner, cmakeFile.defines);

        for (const auto& jsonInclude : compileGroup.value(QLatin1String("includes")).toArray()) {
            const auto include = jsonInclude.toObject();
            const auto path = sourcePathInterner.internPath(include.value(QLatin1String("path")).toString());
            if (path.isValid()) {
                cmakeFile.includes.append(path);
            }
        }

        compileGroups.append(cmakeFile);
    }

    for (const auto& jsonSource : target.value(QLatin1String("sources")).toArray()) {
        const auto source = jsonSource.toObject();
        const auto compileGroupIndex = source.value(QLatin1String("compileGroupIndex")).toInt(-1);
        if (compileGroupIndex < 0 || compileGroupIndex > compileGroups.size()) {
            continue;
        }
        const auto compileGroup = compileGroups.value(compileGroupIndex);
        const auto path = sourcePathInterner.internPath(source.value(QLatin1String("path")).toString());
        if (path.isValid()) {
            compilationData.files[toCanonical(path)] = compileGroup;
        }
    }
    return ret;
}

static QVector<CMakeProjectData> parseCodeModel(const QJsonObject& codeModel, const QDir& replyDir, QUrl& sourcePathInterner, QUrl& buildPathInterner)
{
    QVector<CMakeProjectData> res;
    // for now, we only use the first available configuration and don't support multi configurations
    const auto configuration = codeModel.value(QLatin1String("configurations")).toArray().at(0).toObject();
    const auto projects = configuration.value(QLatin1String("projects")).toArray();
    const auto targets = configuration.value(QLatin1String("targets")).toArray();
    const auto directories = configuration.value(QLatin1String("directories")).toArray();

    for(const auto &projectsValues : projects)
    {
        CMakeProjectData projectRes;
        const auto project = projectsValues.toObject();

        projectRes.name = project.value(QLatin1String("directoryIndexes")).toString();

        if (!project.contains(QLatin1String("directoryIndexes")))
        {
            continue;
        }

        for (const auto& directoryIndex : project.value(QLatin1String("directoryIndexes")).toArray())
        {
            const auto directory = directories.at(directoryIndex.toInt(-1)).toObject();
            if (directory.isEmpty())
            {
                continue;
            }

            if (!directory.contains(QLatin1String("targetIndexes")))
            {
                continue;
            }

            const auto dirSourcePath = QUrl(sourcePathInterner).resolved(directory.value(QLatin1String("source")).toString());
            auto& dirTargets = ret.targets[dirSourcePath];

            for (const auto& targetIndex : directory.value(QLatin1String("targetIndexes")).toArray())
            {
                const auto jsonTarget = targets.at(targetIndex.toInt(-1)).toObject();
                if (jsonTarget.isEmpty())
                {
                    continue;
                }

                const auto targetFile = jsonTarget.value(QLatin1String("jsonFile")).toString();
                const auto target = parseTarget(parseFile(replyDir.absoluteFilePath(targetFile)), sourcePathInterner, buildPathInterner, projectRes.compilationData); //<+++ voy aca

                if (target.name.isEmpty())
                {
                    continue;
                }

                dirTargets.append(target);
            }
        }

        projectRes.compilationData.isValid = !codeModel.isEmpty();
        projectRes.compilationData.rebuildFileForFolderMapping();

        if (!projectRes.compilationData.isValid)
        {
            qWarning() << "failed to parse code model" << codeModel;
        }

        res << projectRes;
    }

    return res;
}

static QHash<QUrl, CMakeProjectData::CMakeFileFlags> parseCMakeFiles(const QJsonObject& cmakeFiles,
                                                                     QUrl& sourcePathInterner)
{
    QHash<Path, CMakeProjectData::CMakeFileFlags> ret;
    for (const auto& jsonInput : cmakeFiles.value(QLatin1String("inputs")).toArray()) {
        const auto input = jsonInput.toObject();
        const auto path = QUrl(input.value(QLatin1String("path")).toString());
        CMakeProjectData::CMakeFileFlags flags;
        flags.isGenerated = input.value(QLatin1String("isGenerated")).toBool();
        flags.isExternal = input.value(QLatin1String("isExternal")).toBool();
        flags.isCMake = input.value(QLatin1String("isCMake")).toBool();
        ret[path] = flags;
    }
    return ret;
}

CMakeProjectData parseReplyIndexFile(const QJsonObject& replyIndex,
                                     const QUrl &sourceDirectory,
                                     const QUrl &buildDirectory)
{
    const auto reply = replyIndex.value(QLatin1String("reply")).toObject();
    const auto clientKDevelop = reply.value(QLatin1String("client-strike")).toObject();
    const auto query = clientKDevelop.value(QLatin1String("query.json")).toObject();
    const auto responses = query.value(QLatin1String("responses")).toArray();
    const auto replyDir = toReplyDir(buildDirectory.toLocalFile());

    QUrl sourcePathInterner(toCanonical(sourceDirectory));
    QUrl buildPathInterner(buildDirectory);

    CMakeProjectData codeModel;
    QHash<Path, CMakeProjectData::CMakeFileFlags> cmakeFiles;

    for (const auto& responseValue : responses) {
        const auto response = responseValue.toObject();
        const auto kind = response.value(QLatin1String("kind"));
        const auto jsonFile = response.value(QLatin1String("jsonFile")).toString();
        const auto jsonFilePath = replyDir.absoluteFilePath(jsonFile);
        if (kind == QLatin1String("codemodel")) {
            codeModel = parseCodeModel(parseFile(jsonFilePath), replyDir, sourcePathInterner, buildPathInterner);
        } else if (kind == QLatin1String("cmakeFiles")) {
            cmakeFiles = parseCMakeFiles(parseFile(jsonFilePath), sourcePathInterner);
        }
    }

    if (!codeModel.compilationData.isValid) {
        qWarning() << "failed to find code model in reply index" << sourceDirectory << buildDirectory << replyIndex;
        return {};
    }

    codeModel.cmakeFiles = cmakeFiles;
    return codeModel;
}
}
}

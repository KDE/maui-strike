/* This file is part of KDevelop
    Copyright 2010 Esben Mose Hansen<kde@mosehansen.dk>

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

#ifndef TEST_CMAKEMANAGER_H
#define TEST_CMAKEMANAGER_H

#include <QTest>

namespace KDevelop {
class IProject;
}

/**
 *  Test of the cmake manager.
 *   + Test that CMakeCache.txt is found, loaded and parsed
 * @author Esben Mose Hansen <kde@mosehansen.dk>
 **/
class TestCMakeManager : public QObject {
    Q_OBJECT
private Q_SLOTS:
    void initTestCase();
    void cleanupTestCase();
    void cleanup();

    void testWithBuildDirProject();
    void testIncludePaths();
    void testRelativePaths();
    void testTargetIncludeDirectories();
    void testTargetIncludePaths();
    void testDefines();
    void testCustomTargetSources();
    void testConditionsInSubdirectoryBasedOnRootVariables();
    void testQt5App();
    void testQt5AppOld();
    void testKF5App();
    void testEnumerateTargets();
    void testFaultyTarget();
    void testParenthesesInTestArguments();
    void testReload();
    void testExecutableOutputPath();
};

#endif // TEST_CMAKEMANAGER_H

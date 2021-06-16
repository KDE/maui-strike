import info
from Package.CMakePackageBase import *


class subinfo(info.infoclass):
    def setTargets(self):
        self.svnTargets['master'] = 'https://invent.kde.org/maui/nota.git'

        for ver in ['1.2.2']:
            self.targets[ver] = 'https://download.kde.org/stable/maui/nota/1.2.2/nota-%s.tar.xz' % ver
            self.archiveNames[ver] = 'nota-%s.tar.gz' % ver
            self.targetInstSrc[ver] = 'nota-%s' % ver

        self.description = "Browse, create and edit text files."
        self.defaultTarget = '1.2.2'

    def setDependencies(self):
        self.runtimeDependencies["virtual/base"] = None
        self.runtimeDependencies["libs/qt5/qtbase"] = None


class Package(CMakePackageBase):
    def __init__(self, **args):
        CMakePackageBase.__init__(self)
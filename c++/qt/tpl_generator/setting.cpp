#include "setting.h"
#include <QDir>
#include <QSettings>
#include <QString>

void Setting::setErlDir(const QString &dir)
{
    QSettings *writer = new QSettings(getUserDataFile(), QSettings::IniFormat);
    writer->setValue("/dir/erl_dir", dir);
    delete writer;
}

void Setting::setLuaDir(const QString &dir)
{
    QSettings *writer = new QSettings(getUserDataFile(), QSettings::IniFormat);
    writer->setValue("/dir/lua_dir", dir);
    delete writer;
}

void Setting::setErlMapDir(const QString &dir)
{
    QSettings *writer = new QSettings(getUserDataFile(), QSettings::IniFormat);
    writer->setValue("/dir/erl_map_dir", dir);
    delete writer;
}

void Setting::setCMapDir(const QString &dir)
{
    QSettings *writer = new QSettings(getUserDataFile(), QSettings::IniFormat);
    writer->setValue("/dir/c_map_dir", dir);
    delete writer;
}

QString &Setting::getUserDataFile()
{
    if(m_userDataFile.isEmpty()){
        QDir dir = QDir::homePath();
        m_userDataFile = dir.absoluteFilePath("fbird_gen_config.setting");
    }

    return m_userDataFile;
}

#ifndef SETTING_H
#define SETTING_H

#include <QSettings>
#include <QString>
#include <QDebug>


class Setting
{
private:
    Setting(){}
    Setting(const Setting&);
    Setting& operator = (const Setting &);

private:
    QString m_erl_dir;
    QString m_lua_dir;
    QString m_cs_dir;
    QString m_erl_map_dir;
    QString m_c_map_dir;
    QString m_userDataFile;

public:
    static Setting & getInstatnce(){
        static Setting instance;
        return instance;
    }


    const QString & getErlDir(){
        if(m_erl_dir.isEmpty()){
            QSettings *reader = new QSettings(getUserDataFile(), QSettings::IniFormat);
            m_erl_dir = reader->value("/dir/erl_dir").toString();
            delete reader;
        }
        return m_erl_dir;
    }

    const QString & getLuaDir(){
        if(m_lua_dir.isEmpty()){
            QSettings *reader = new QSettings(getUserDataFile(), QSettings::IniFormat);
            m_lua_dir = reader->value("/dir/lua_dir").toString();
            delete reader;
        }
        return m_lua_dir;
    }

    const QString & getCsDir(){
        if(m_cs_dir.isEmpty()){
            QSettings *reader = new QSettings(getUserDataFile(), QSettings::IniFormat);
            m_cs_dir = reader->value("/dir/cs_dir").toString();
            delete reader;
        }
        return m_cs_dir;
    }

    const QString & getErlMapDir(){
        if(m_erl_map_dir.isEmpty()){
            QSettings *reader = new QSettings(getUserDataFile(), QSettings::IniFormat);
            m_erl_map_dir = reader->value("/dir/erl_map_dir").toString();
            delete reader;
        }
        return m_erl_map_dir;
    }

    const QString & getCMapDir(){
        if(m_c_map_dir.isEmpty()){
            QSettings *reader = new QSettings(getUserDataFile(), QSettings::IniFormat);
            m_c_map_dir = reader->value("/dir/c_map_dir").toString();
            qDebug() << "m_c_map_dir:" << m_c_map_dir;
            delete reader;
        }
        return m_c_map_dir;
    }

    void setErlDir(const QString & dir);
    void setLuaDir(const QString & dir);
    void setErlMapDir(const QString & dir);
    void setCMapDir(const QString & dir);

private:
    QString & getUserDataFile();

};

#endif // SETTING_H

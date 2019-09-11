#-------------------------------------------------
#
# Project created by QtCreator 2019-09-06T17:43:20
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = tpl_generator
TEMPLATE = app

# The following define makes your compiler emit warnings if you use
# any feature of Qt which has been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0


SOURCES += \
        main.cpp \
        mainwindow.cpp \
    modtab.cpp \
    maptab.cpp \
    exportitem.cpp \
    setting.cpp

HEADERS += \
        mainwindow.h \
    modtab.h \
    maptab.h \
    style.h \
    exportitem.h \
    util.h \
    setting.h

FORMS += \
    modtab.ui \
    maptab.ui

RESOURCES += \
    resource.qrc

DISTFILES += \
    my_style_sheet.qss \
    cfg_game_config.json

win32:{

    file_pathes += "\"$$PWD/*.json\""

    CONFIG(release, debug|release):{
        destination_pathes += $$OUT_PWD/release/
    }
    else:CONFIG(debug, debug|release):{
        destination_pathes += $$OUT_PWD/debug/
    }

    for(file_path,file_pathes){
        file_path ~= s,/,\\,g
        for(dest_path,destination_pathes){
            dest_path ~= s,/,\\,g
            QMAKE_POST_LINK += $$quote(xcopy $${file_path} $${dest_path} /I /Y $$escape_expand(\n\t))
         }
    }
}

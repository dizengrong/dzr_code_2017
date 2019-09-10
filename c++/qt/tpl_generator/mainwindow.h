#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "modtab.h"

#include <QMainWindow>
#include <QProcess>

class MainWindow : public QMainWindow
{
    Q_OBJECT
private:
    QMenu *m_tool_menu;
    QAction *m_export_all_erl_act;
    QAction *m_export_all_lua_act;
    QAction *m_export_all_cs_act;
    QTabWidget *m_tabWidget;
    ModTab *m_mod_tab;
    QProcess *m_pyProcess;

private slots:
    void onExportAllErlModAction();
    void onExportAllLuaModAction();
    void onExportAllCsModAction();
    void loadStyleSheet(const QString &styleSheetFile);

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();
    void exportOneFile(const QString& save_dir, const QString& tpl_file);
private:
    void createMenus();
    void createActions();
    void initTabs(QWidget* centralWidget);
};

#endif // MAINWINDOW_H

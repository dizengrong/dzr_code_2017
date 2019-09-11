#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "maptab.h"
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
    MapTab *m_map_tab;
    QProcess *m_pyProcess;
    QString m_excel_src_path;

private slots:
    void onExportAllErlModAction();
    void onExportAllLuaModAction();
    void onExportAllCsModAction();
    void loadStyleSheet(const QString &styleSheetFile);
    void onTimerTest();

public:
    MainWindow(QWidget *parent, QProcess *process);
    ~MainWindow();
    void exportOneFile(const QString& save_dir, const QString& tpl_file);
    void exportBySheet(const QString& sheet);
    const QString getExcelSrcPath() const;
private:
    void createMenus();
    void createActions();
    void initTabs(QWidget* centralWidget);
    void executePythonCmd(const QString &cmd);
};

#endif // MAINWINDOW_H

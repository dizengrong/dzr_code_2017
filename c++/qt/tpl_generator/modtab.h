#ifndef MODTAB_H
#define MODTAB_H

#include "exportitem.h"

#include <QAction>
#include <QPushButton>
#include <QTimer>
#include <QWidget>

namespace Ui {
class ModTab;
}

class MainWindow;

class ModTab : public QWidget
{
    Q_OBJECT

public:
    explicit ModTab(MainWindow *parent = nullptr);
    ~ModTab();
    bool loadConfigJson(const QString &jsonFile);
    void showWith(const QList<ExportItem> &datas);

private:
    Ui::ModTab *ui;
    QList<ExportItem> m_exports;
    QMenu *m_context_menu;
    QAction *m_openDirAct;
    QTimer *m_timer;
    MainWindow* m_mainWindow;

private slots:
     void openDirectory();
     void onCellDoubleClicked(int row, int column);
     void onSearchEvent(const QString &text);
     void onSearchShowEvent();
     void contextMenuEvent(QContextMenuEvent *event); //右键默认槽
     void on_m_btn_erl_dir_clicked();
     void on_m_btn_lua_dir_clicked();
     void onExportBySheet();
     void onOpenExcelFile();
     void on_m_btn_all_erl_clicked();
     void on_m_btn_all_lua_clicked();
};

#endif // MODTAB_H

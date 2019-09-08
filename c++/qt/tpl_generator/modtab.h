#ifndef MODTAB_H
#define MODTAB_H

#include "exportitem.h"

#include <QPushButton>
#include <QWidget>

namespace Ui {
class ModTab;
}

class ModTab : public QWidget
{
    Q_OBJECT

public:
    explicit ModTab(QWidget *parent = nullptr);
    ~ModTab();
    bool loadConfigJson(const QString &jsonFile);
    void showWith(const QList<ExportItem> &datas);

private:
    Ui::ModTab *ui;
    QList<ExportItem> m_exports;
    QPushButton *operatorBtn;
};

#endif // MODTAB_H

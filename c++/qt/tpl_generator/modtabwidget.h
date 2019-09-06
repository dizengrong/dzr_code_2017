#ifndef MODTABWIDGET_H
#define MODTABWIDGET_H

#include <QTabWidget>

namespace Ui {
class ModTabWidget;
}

class ModTabWidget : public QTabWidget
{
    Q_OBJECT

public:
    explicit ModTabWidget(QWidget *parent = 0);
    ~ModTabWidget();

private:
    Ui::ModTabWidget *ui;
};

#endif // MODTABWIDGET_H

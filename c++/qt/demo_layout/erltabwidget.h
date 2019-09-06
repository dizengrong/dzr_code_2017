#ifndef ERLTABWIDGET_H
#define ERLTABWIDGET_H

#include <QTabWidget>

namespace Ui {
class ErlTabWidget;
}

class ErlTabWidget : public QTabWidget
{
    Q_OBJECT

public:
    explicit ErlTabWidget(QWidget *parent = 0);
    ~ErlTabWidget();

private:
    Ui::ErlTabWidget *ui;
};

#endif // ERLTABWIDGET_H

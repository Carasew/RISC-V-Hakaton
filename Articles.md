# RISC-V-Hakaton
* RISC-V
1. https://github.com/MPSU/APS
2. [https://github.com/MPSU/APS](https://github.com/ultraembedded/riscv)
* Verilog
3. https://portal-ed.ru/index.php/uchebnik-verilog
4. https://kit-e.ru/circuit/kratkij-kurs-hdl-chast-2-1/
5. https://www.chipverify.com/verilog/verilog-tutorial
* Assembler
6. https://blic.fandom.com/ru/wiki/%D0%9A%D1%80%D0%B0%D1%82%D0%BA%D0%B8%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D1%87%D0%B5%D0%BD%D1%8C_%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4_%D0%B0%D1%81%D1%81%D0%B5%D0%BC%D0%B1%D0%BB%D0%B5%D1%80%D0%B0
7. http://natalia.appmat.ru/c&c++/assembler.html


Оптимизация RISC-V

Конфликты конвейера
1. Структурные конфликты
* Дублирование ресурсов
* Конвейеризация исполнительных устройств
* Изменение структуры
2. Конфликты по данным
* Чтение после записи (RAW)
* Запись после чтения (WAR)
* Запись после записи (WAW)
3. Конфликты по управлению
* Статическое предсказание переходов
* Динамическое изменение переходов
* Буферизация адресов переходов и команд из точки перехода
* Буфер цикла

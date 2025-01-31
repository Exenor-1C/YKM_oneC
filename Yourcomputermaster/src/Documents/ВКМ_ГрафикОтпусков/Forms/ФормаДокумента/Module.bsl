
&НаСервере
Процедура ПроверкаПревышенияДней()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВТ_ГрафикОтпусков.Сотрудник КАК Сотрудник,
	               |	ВТ_ГрафикОтпусков.ДатаНачала КАК ДатаНачала,
	               |	ВТ_ГрафикОтпусков.ДатаОкончания КАК ДатаОкончания
	               |ПОМЕСТИТЬ ВТ_Отпуска
	               |ИЗ
	               |	&ВТ_ГрафикОтпусков КАК ВТ_ГрафикОтпусков
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_Отпуска.Сотрудник КАК Сотрудник,
	               |	РАЗНОСТЬДАТ(ВТ_Отпуска.ДатаНачала, ВТ_Отпуска.ДатаОкончания, ДЕНЬ) + 1 КАК КоличествоДней
	               |ПОМЕСТИТЬ ВТ_КолВоДней
	               |ИЗ
	               |	ВТ_Отпуска КАК ВТ_Отпуска
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_КолВоДней.Сотрудник КАК Сотрудник,
	               |	СУММА(ВТ_КолВоДней.КоличествоДней) КАК КоличествоДней
	               |ПОМЕСТИТЬ втИтог
	               |ИЗ
	               |	ВТ_КолВоДней КАК ВТ_КолВоДней
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВТ_КолВоДней.Сотрудник
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	втИтог.Сотрудник КАК Сотрудник
	               |ИЗ
	               |	втИтог КАК втИтог
	               |ГДЕ
	               |	втИтог.КоличествоДней > 28";
	Запрос.УстановитьПараметр("ВТ_ГрафикОтпусков", Объект.ОтпускаСотрудников.Выгрузить());
	
	Результат = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Сотрудник");
	СписокСотрудников = Новый СписокЗначений;
	СписокСотрудников.ЗагрузитьЗначения(Результат);
	УсловноеОформление.Элементы.Очистить();
	ЭлементОформления = УсловноеОформление.Элементы.Добавить();
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.ОтпускаСотрудников.Сотрудник");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке;
	ЭлементОтбора.ПравоеЗначение = СписокСотрудников;
	ЭлементОтбора.Использование = Истина;
	
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("ЦветФона", WEBЦвета.Красный);
	
	ПолеОформления = ЭлементОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("ОтпускаСотрудников");
	ПолеОформления.Использование = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтпускаСотрудниковПриИзменении(Элемент)
	
	ПроверкаПревышенияДней();
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьГрафикОтпусков(Команда)
	
	СтрокаАдрес = ОткрытьФормуНаСервере();
	Структура = Новый Структура("АдресВрХр", СтрокаАдрес);
	Форма = ОткрытьФорму("Документ.ВКМ_ГрафикОтпусков.Форма.ФормаГрафикаОтпусков", Структура,ЭтаФорма,,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаСервере
Функция ОткрытьФормуНаСервере()
	
	Возврат ПоместитьВоВременноеХранилище(Объект.ОтпускаСотрудников.Выгрузить(), УникальныйИдентификатор);
	
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПроверкаПревышенияДней();
	
КонецПроцедуры

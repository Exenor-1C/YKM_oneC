#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаполнитьСотрудников(Команда)
	ЗаполнитьСотрудниковНаСервере();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере

Процедура ЗаполнитьСотрудниковНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ВзаиморасчетыССотрудникамиОстатки.Сотрудник КАК Сотрудник,
	               |	ВКМ_ВзаиморасчетыССотрудникамиОстатки.Подразделение КАК Подразделение,
	               |	ЕСТЬNULL(ВКМ_ВзаиморасчетыССотрудникамиОстатки.СуммаОстаток, 0) КАК Сумма
	               |ИЗ
	               |	РегистрНакопления.ВКМ_ВзаиморасчетыССотрудниками.Остатки КАК ВКМ_ВзаиморасчетыССотрудникамиОстатки
	               |ГДЕ
	               |	ВКМ_ВзаиморасчетыССотрудникамиОстатки.СуммаОстаток > 0";
	
	Результат = Запрос.Выполнить().Выбрать();
	
	Пока Результат.Следующий() Цикл
		
		Сотрудник = Объект.Сотрудники.Добавить();
		Сотрудник.Сотрудник = Результат.Сотрудник;
		Сотрудник.Подразделение = РЕзультат.Подразделение;
		Сотрудник.Сумма = Результат.Сумма;
		
	КонецЦикла;
	
КонецПроцедуры


#КонецОбласти
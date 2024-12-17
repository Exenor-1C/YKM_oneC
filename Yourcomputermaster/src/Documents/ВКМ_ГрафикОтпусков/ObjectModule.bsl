#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий
Процедура ОбработкаПроведения(Отказ, Режим)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Движения.ВКМ_ГрафикОтпусковПлан.Записывать = Истина;
	Движения.ВКМ_ГрафикОтпусковПлан.Записать();
	
	Для Каждого Строка Из ОтпускаСотрудников Цикл
		
		Движение = Движения.ВКМ_ГрафикОтпусковПлан.Добавить();
		Движение.ДатаНачала = Строка.ДатаНачала;
		Движение.ДатаОкончания = Строка.ДатаОкончания;
		Движение.Период = Дата;
		Движение.Подразделение = Строка.Подразделение;
		ДВижение.Сотрудник = Строка.Сотрудник;
		Движение.Год = Год;
		Движение.КоличествоДней = (Строка.ДатаОкончания - Строка.ДатаНачала) / 86400;
		Движение.Регистратор = Ссылка;
		
	КонецЦикла;
	
	Движения.ВКМ_ГрафикОтпусковПлан.Записать();
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
